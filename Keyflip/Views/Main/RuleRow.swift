//
//  RuleRow.swift
//  Keyflip
//

import SwiftUI

/// One app and the input source it switches to.
struct RuleRow: View {
    let rule: AppRule
    let icon: NSImage
    let sources: [InputSource]
    let isAvailable: Bool
    @Binding var selection: String
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 20, height: 20)
            Text(rule.appName)
            Spacer()
            Picker(rule.appName, selection: $selection) {
                if !isAvailable {
                    // The source was disabled in System Settings; keep the rule visible
                    // instead of silently changing it.
                    Text("Unavailable").tag(rule.sourceID)
                }
                ForEach(sources) { source in
                    Text(source.name).tag(source.id)
                }
            }
            .labelsHidden()
            .fixedSize()
            Button(action: onRemove) {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.borderless)
            .help("Remove \(rule.appName)")
        }
    }
}

#Preview {
    @Previewable @State var selection = "abc"
    Form {
        RuleRow(
            rule: AppRule(bundleID: "com.apple.dt.Xcode", appName: "Xcode", sourceID: selection),
            icon: NSImage(systemSymbolName: "hammer", accessibilityDescription: nil) ?? NSImage(),
            sources: [InputSource(id: "abc", name: "ABC"), InputSource(id: "pinyin", name: "Pinyin - Simplified")],
            isAvailable: true,
            selection: $selection,
            onRemove: {}
        )
    }
    .formStyle(.grouped)
}
