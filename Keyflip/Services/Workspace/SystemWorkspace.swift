//
//  SystemWorkspace.swift
//  Keyflip
//

import AppKit
import Observation

/// `NSWorkspace`-backed app information, plus the app-activation events that drive switching.
@Observable
final class SystemWorkspace: WorkspaceProviding {
    private(set) var runningApps: [AppIdentity] = []

    /// Called on the main thread whenever another app becomes active.
    @ObservationIgnored var onAppActivated: ((AppIdentity) -> Void)?

    @ObservationIgnored private let workspace = NSWorkspace.shared
    @ObservationIgnored private let ownBundleID = Bundle.main.bundleIdentifier
    @ObservationIgnored private var observers: [NSObjectProtocol] = []
    @ObservationIgnored private var iconCache: [String: NSImage] = [:]

    init() {
        refreshRunningApps()
        startObserving()
    }

    isolated deinit {
        observers.forEach(workspace.notificationCenter.removeObserver)
    }

    var frontmostApp: AppIdentity? {
        workspace.frontmostApplication.flatMap(AppIdentity.init)
    }

    func icon(forBundleID bundleID: String) -> NSImage {
        if let cached = iconCache[bundleID] {
            return cached
        }
        let icon = workspace.urlForApplication(withBundleIdentifier: bundleID)
            .map { workspace.icon(forFile: $0.path(percentEncoded: false)) }
            ?? NSImage(systemSymbolName: "app.dashed", accessibilityDescription: nil)
            ?? NSImage()
        iconCache[bundleID] = icon
        return icon
    }

    func appIdentity(at url: URL) -> AppIdentity? {
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessing { url.stopAccessingSecurityScopedResource() }
        }
        guard let bundleID = Bundle(url: url)?.bundleIdentifier else {
            return nil
        }
        let displayName = FileManager.default.displayName(atPath: url.path(percentEncoded: false))
        return AppIdentity(bundleID: bundleID, name: (displayName as NSString).deletingPathExtension)
    }

    private func refreshRunningApps() {
        runningApps = workspace.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != ownBundleID }
            .compactMap(AppIdentity.init)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func startObserving() {
        let center = workspace.notificationCenter
        let listChanges = [NSWorkspace.didLaunchApplicationNotification, NSWorkspace.didTerminateApplicationNotification]
        observers = listChanges.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.refreshRunningApps()
                }
            }
        }
        observers.append(
            center.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] notification in
                let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
                guard let identity = app.flatMap(AppIdentity.init) else { return }
                MainActor.assumeIsolated {
                    self?.onAppActivated?(identity)
                }
            }
        )
    }
}

private extension AppIdentity {
    nonisolated init?(_ app: NSRunningApplication) {
        guard let bundleID = app.bundleIdentifier else { return nil }
        self.init(bundleID: bundleID, name: app.localizedName ?? bundleID)
    }
}
