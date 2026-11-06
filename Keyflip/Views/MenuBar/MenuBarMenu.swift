//
//  MenuBarMenu.swift
//  Keyflip
//

import SwiftUI

struct MenuBarMenu: View {
    @Bindable var viewModel: MenuBarViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text("Input: \(viewModel.currentSourceName)")

        if let appName = viewModel.frontmostAppName {
            Picker("Input for \(appName)", selection: $viewModel.frontmostAppSourceID) {
                Text("Use Default").tag(String?.none)
                Divider()
                if let sourceID = viewModel.frontmostAppSourceID, !viewModel.isAvailable(sourceID) {
                    Text("Unavailable").tag(Optional(sourceID))
                }
                ForEach(viewModel.sources) { source in
                    Text(source.name).tag(Optional(source.id))
                }
            }
        }

        Divider()

        Toggle("Auto-Switch", isOn: $viewModel.isEnabled)

        Button("Open Keyflip") {
            // Menu bar clicks don't activate the app, so the window would
            // otherwise open behind the frontmost app.
            NSApp.activate()
            openWindow(id: MainView.windowID)
        }

        Divider()

        Button("Quit Keyflip", action: viewModel.quit)
            .keyboardShortcut("q")
    }
}
