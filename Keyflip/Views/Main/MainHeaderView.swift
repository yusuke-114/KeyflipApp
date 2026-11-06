//
//  MainHeaderView.swift
//  Keyflip
//

import SwiftUI

/// Explains what Keyflip does and shows the input source in use.
struct MainHeaderView: View {
    let currentSourceName: String

    var body: some View {
        HStack(spacing: 14) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text("Keyflip")
                    .font(.title2.bold())
                Text("Switches your input source automatically whenever you move to another app.")
                    .foregroundStyle(.secondary)
                Label(currentSourceName, systemImage: "keyboard")
                    .font(.callout)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    Form {
        MainHeaderView(currentSourceName: "Pinyin - Simplified")
    }
    .formStyle(.grouped)
}
