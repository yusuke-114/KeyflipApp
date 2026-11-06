//
//  AddAppMenu.swift
//  Keyflip
//

import SwiftUI

/// Adds a rule for a running app, or for one picked from /Applications.
struct AddAppMenu: View {
    let runningApps: [AppIdentity]
    let onAdd: (AppIdentity) -> Void
    let onChoose: () -> Void

    var body: some View {
        Menu {
            Section("Running Apps") {
                ForEach(runningApps, id: \.bundleID) { app in
                    Button(app.name) { onAdd(app) }
                }
            }
            Divider()
            Button("Choose from Applications…", action: onChoose)
        } label: {
            Label("Add App", systemImage: "plus")
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}
