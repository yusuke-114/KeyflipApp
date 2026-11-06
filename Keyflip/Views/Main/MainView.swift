//
//  MainView.swift
//  Keyflip
//

import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    static let windowID = "main"

    @Bindable var viewModel: MainViewModel
    @State private var isChoosingApp = false

    var body: some View {
        Form {
            Section {
                MainHeaderView(currentSourceName: viewModel.currentSourceName)
            }

            Section {
                GeneralSettingsView(viewModel: viewModel)
            }

            Section {
                if viewModel.rules.isEmpty {
                    Text("Add an app to choose the input source it should always use.")
                        .foregroundStyle(.secondary)
                }
                ForEach(viewModel.rules) { rule in
                    RuleRow(
                        rule: rule,
                        icon: viewModel.icon(for: rule),
                        sources: viewModel.sources,
                        isAvailable: viewModel.isAvailable(rule.sourceID),
                        selection: sourceBinding(for: rule),
                        onRemove: { viewModel.remove(rule) }
                    )
                }
            } header: {
                HStack {
                    Text("Apps")
                    Spacer()
                    AddAppMenu(
                        runningApps: viewModel.addableApps,
                        onAdd: viewModel.add,
                        onChoose: { isChoosingApp = true }
                    )
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .frame(minHeight: 360)
        .fileImporter(isPresented: $isChoosingApp, allowedContentTypes: [.application]) { result in
            if case .success(let url) = result {
                viewModel.addApp(at: url)
            }
        }
        .fileDialogDefaultDirectory(URL(filePath: "/Applications"))
    }

    private func sourceBinding(for rule: AppRule) -> Binding<String> {
        Binding(
            get: { rule.sourceID },
            set: { viewModel.setSource($0, for: rule) }
        )
    }
}

private struct GeneralSettingsView: View {
    @Bindable var viewModel: MainViewModel

    var body: some View {
        Toggle("Switch input sources automatically", isOn: $viewModel.isEnabled)
        Toggle("Show input source when switching apps", isOn: $viewModel.showsIndicator)
        Toggle("Launch at login", isOn: $viewModel.launchesAtLogin)
        if let error = viewModel.launchAtLoginError {
            Text(error)
                .font(.caption)
                .foregroundStyle(.red)
        }
        Picker("Other apps", selection: $viewModel.defaultSourceID) {
            Text("Keep current input").tag(String?.none)
            Divider()
            if let sourceID = viewModel.defaultSourceID, !viewModel.isAvailable(sourceID) {
                Text("Unavailable").tag(Optional(sourceID))
            }
            ForEach(viewModel.sources) { source in
                Text(source.name).tag(Optional(source.id))
            }
        }
    }
}
