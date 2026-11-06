//
//  MainViewModel.swift
//  Keyflip
//

import AppKit
import Observation

/// State and actions for the main window.
@Observable
final class MainViewModel {
    private let store: RuleStore
    private let catalog: InputSourceCatalog
    private let switcher: AutoSwitcher
    private let launchAtLogin: LaunchAtLoginService
    private let workspace: any WorkspaceProviding

    init(
        store: RuleStore,
        catalog: InputSourceCatalog,
        switcher: AutoSwitcher,
        launchAtLogin: LaunchAtLoginService,
        workspace: any WorkspaceProviding
    ) {
        self.store = store
        self.catalog = catalog
        self.switcher = switcher
        self.launchAtLogin = launchAtLogin
        self.workspace = workspace
    }

    // MARK: - State

    var sources: [InputSource] { catalog.sources }

    var currentSourceName: String { catalog.currentSourceName ?? String(localized: "Unknown") }

    var rules: [AppRule] { store.rules }

    /// Running apps that don't have a rule yet.
    var addableApps: [AppIdentity] {
        workspace.runningApps.filter { store.rule(for: $0.bundleID) == nil }
    }

    var isEnabled: Bool {
        get { store.isEnabled }
        set {
            store.isEnabled = newValue
            switcher.reapply()
        }
    }

    var defaultSourceID: String? {
        get { store.defaultSourceID }
        set {
            store.defaultSourceID = newValue
            switcher.reapply()
        }
    }

    var showsIndicator: Bool {
        get { store.showsIndicator }
        set { store.showsIndicator = newValue }
    }

    var launchesAtLogin: Bool {
        get { launchAtLogin.isEnabled }
        set { launchAtLogin.setEnabled(newValue) }
    }

    var launchAtLoginError: String? { launchAtLogin.errorMessage }

    func isAvailable(_ sourceID: String) -> Bool {
        catalog.contains(sourceID)
    }

    func icon(for rule: AppRule) -> NSImage {
        workspace.icon(forBundleID: rule.bundleID)
    }

    // MARK: - Actions

    /// New rules start with the input source the user is typing in right now.
    func add(_ app: AppIdentity) {
        guard let sourceID = catalog.currentSourceID ?? catalog.sources.first?.id else {
            return
        }
        store.setSource(sourceID, for: app)
        switcher.reapply()
    }

    func addApp(at url: URL) {
        guard let app = workspace.appIdentity(at: url) else { return }
        add(app)
    }

    func setSource(_ sourceID: String, for rule: AppRule) {
        store.setSource(sourceID, for: rule.app)
        switcher.reapply()
    }

    func remove(_ rule: AppRule) {
        store.removeRule(for: rule.bundleID)
        switcher.reapply()
    }
}
