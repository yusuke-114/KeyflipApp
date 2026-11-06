//
//  InputSourceHUD.swift
//  Keyflip
//

import AppKit
import SwiftUI

/// A small floating panel that fades out on its own. It never takes focus or
/// activates Keyflip, so typing in the app the user just moved to is unaffected.
final class InputSourceHUD: InputSourceIndicating {
    private static let visibleDuration: Duration = .seconds(1.2)
    private static let fadeDuration: Duration = .seconds(0.3)

    private lazy var hostingView = NSHostingView(rootView: InputSourceHUDView(sourceName: "", appName: ""))
    private lazy var panel = makePanel()
    private var hideTask: Task<Void, Never>?

    func show(_ source: InputSource, for app: AppIdentity) {
        hostingView.rootView = InputSourceHUDView(sourceName: source.name, appName: app.name)
        position(for: app)

        hideTask?.cancel()
        panel.orderFrontRegardless()
        panel.animator().alphaValue = 1
        hideTask = Task { [weak self] in
            do {
                try await Task.sleep(for: Self.visibleDuration)
                self?.panel.animator().alphaValue = 0
                try await Task.sleep(for: Self.fadeDuration)
                self?.panel.orderOut(nil)
            } catch {
                // Cancelled because another app became active; that call owns the panel now.
            }
        }
    }

    private func position(for app: AppIdentity) {
        let size = hostingView.fittingSize
        let origin: CGPoint
        if let window = frontWindowFrame(of: app),
           let screen = screen(containing: CGPoint(x: window.midX, y: window.midY)) {
            origin = HUDPlacement.origin(for: size, inWindow: window, on: screen.visibleFrame)
        } else if let screen = screen(containing: NSEvent.mouseLocation) {
            // No visible window, e.g. Finder showing only the desktop. The mouse
            // marks where the user just clicked.
            origin = HUDPlacement.origin(for: size, onScreen: screen.visibleFrame)
        } else {
            return
        }
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    /// The app's frontmost window in AppKit coordinates, if it has one on screen.
    private func frontWindowFrame(of app: AppIdentity) -> CGRect? {
        guard
            let pid = runningApplication(for: app)?.processIdentifier,
            let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]],
            let bounds = HUDPlacement.frontWindowBounds(of: pid, in: windowList),
            let primaryScreen = NSScreen.screens.first
        else {
            return nil
        }
        return HUDPlacement.appKitRect(fromWindowServer: bounds, primaryScreenHeight: primaryScreen.frame.height)
    }

    /// The app that just became active is normally frontmost; the lookup by bundle ID
    /// covers the case where the workspace hasn't caught up yet.
    private func runningApplication(for app: AppIdentity) -> NSRunningApplication? {
        let frontmost = NSWorkspace.shared.frontmostApplication
        if frontmost?.bundleIdentifier == app.bundleID {
            return frontmost
        }
        return NSRunningApplication.runningApplications(withBundleIdentifier: app.bundleID).first
    }

    private func screen(containing point: CGPoint) -> NSScreen? {
        NSScreen.screens.first { $0.frame.contains(point) } ?? NSScreen.main
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        // Keyflip is almost never the active app, so the panel must not hide with it.
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.alphaValue = 0
        panel.contentView = hostingView
        return panel
    }
}

private struct InputSourceHUDView: View {
    let sourceName: String
    let appName: String

    var body: some View {
        VStack(spacing: 4) {
            Label(sourceName, systemImage: "keyboard")
                .font(.title3.weight(.semibold))
            Text(appName)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        // The panel is sized from `fittingSize`, so ask for the full text width.
        .fixedSize()
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
        // Room for the glass edge and shadow inside the transparent panel.
        .padding(16)
    }
}

#Preview {
    InputSourceHUDView(sourceName: "Pinyin - Simplified", appName: "WeChat")
}
