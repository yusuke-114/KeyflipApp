//
//  MenuBarViewModel.swift
//  Keyflip
//

import AppKit
import Observation

/// State and actions for the menu bar menu.
@Observable
final class MenuBarViewModel {
    private let store: RuleStore
    private let catalog: InputSourceCatalog
    private let switcher: AutoSwitcher

    init(store: RuleStore, catalog: InputSourceCatalog, switcher: AutoSwitcher) {
        self.store = store
        self.catalog = catalog
        self.switcher = switcher
    }

    // MARK: - State

    var sources: [InputSource] { catalog.sources }

    var currentSourceName: String { catalog.currentSourceName ?? String(localized: "Unknown") }

    /// The app the user was in before opening the menu.
    var frontmostAppName: String? { switcher.frontmostApp?.name }

    /// The frontmost app's rule. `nil` means it follows the default.
    var frontmostAppSourceID: String? {
        get {
            switcher.frontmostApp.flatMap { store.rule(for: $0.bundleID)?.sourceID }
        }
        set {
            guard let app = switcher.frontmostApp else { return }
            store.setSource(newValue, for: app)
            switcher.reapply()
        }
    }

    var isEnabled: Bool {
        get { store.isEnabled }
        set {
            store.isEnabled = newValue
            switcher.reapply()
        }
    }

    func isAvailable(_ sourceID: String) -> Bool {
        catalog.contains(sourceID)
    }

    // MARK: - Actions

    func quit() {
        NSApp.terminate(nil)
    }
}
