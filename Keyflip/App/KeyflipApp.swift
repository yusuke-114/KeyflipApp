//
//  KeyflipApp.swift
//  Keyflip
//

import SwiftUI

final class KeyflipAppDelegate: NSObject, NSApplicationDelegate {
    /// AppKit can't open a SwiftUI window by itself, so SwiftUI provides this once it's running.
    var showMainWindow: (() -> Void)?

    /// Switching keeps working in the background after the window closes.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    /// Clicking the Dock icon, or opening Keyflip again from Finder, brings the
    /// window back, including when it wasn't shown at launch.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        guard !hasVisibleWindows, let showMainWindow else { return true }
        showMainWindow()
        return false
    }
}

@main
struct KeyflipApp: App {
    @NSApplicationDelegateAdaptor(KeyflipAppDelegate.self) private var appDelegate
    @State private var container = AppContainer()

    var body: some Scene {
        Window("Keyflip", id: MainView.windowID) {
            MainView(viewModel: container.mainViewModel)
        }
        .windowResizability(.contentSize)
        // Started at login, Keyflip works quietly from the menu bar; opened by
        // hand, it shows its window. Restoring the last session would undo this.
        .defaultLaunchBehavior(container.mainViewModel.launchesAtLogin ? .suppressed : .presented)
        .restorationBehavior(.disabled)

        MenuBarExtra {
            MenuBarMenu(viewModel: container.menuBarViewModel)
        } label: {
            MenuBarLabel { openWindow in
                appDelegate.showMainWindow = {
                    NSApp.activate()
                    openWindow(id: MainView.windowID)
                }
            }
        }
    }
}

/// The menu bar icon. It exists from launch on, even when the window doesn't,
/// so it's where the app delegate gets a way to open the window.
private struct MenuBarLabel: View {
    let onAppear: (OpenWindowAction) -> Void
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Image(systemName: "keyboard")
            .accessibilityLabel(Text("Keyflip"))
            .onAppear { onAppear(openWindow) }
    }
}
