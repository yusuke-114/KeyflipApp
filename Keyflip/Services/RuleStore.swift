//
//  RuleStore.swift
//  Keyflip
//

import Foundation
import Observation

/// The user's per-app rules and switching preferences, persisted in UserDefaults.
@Observable
final class RuleStore {
    private enum Key {
        static let rules = "rules"
        static let isEnabled = "isEnabled"
        static let defaultSourceID = "defaultSourceID"
        static let showsIndicator = "showsIndicator"
    }

    /// Sorted by app name for display.
    private(set) var rules: [AppRule]

    var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: Key.isEnabled) }
    }

    /// Used for apps without a rule. `nil` leaves the input source unchanged.
    var defaultSourceID: String? {
        didSet { defaults.set(defaultSourceID, forKey: Key.defaultSourceID) }
    }

    /// Briefly shows the input source in use whenever another app becomes active.
    var showsIndicator: Bool {
        didSet { defaults.set(showsIndicator, forKey: Key.showsIndicator) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let data = defaults.data(forKey: Key.rules)
        rules = data.flatMap { try? JSONDecoder().decode([AppRule].self, from: $0) } ?? []
        isEnabled = defaults.object(forKey: Key.isEnabled) as? Bool ?? true
        defaultSourceID = defaults.string(forKey: Key.defaultSourceID)
        showsIndicator = defaults.object(forKey: Key.showsIndicator) as? Bool ?? true
    }

    func rule(for bundleID: String) -> AppRule? {
        rules.first { $0.bundleID == bundleID }
    }

    /// The input source to use when `bundleID` becomes active, if any.
    func targetSourceID(for bundleID: String) -> String? {
        rule(for: bundleID)?.sourceID ?? defaultSourceID
    }

    /// Passing `nil` removes the app's rule so it falls back to the default.
    func setSource(_ sourceID: String?, for app: AppIdentity) {
        rules.removeAll { $0.bundleID == app.bundleID }
        if let sourceID {
            rules.append(AppRule(bundleID: app.bundleID, appName: app.name, sourceID: sourceID))
            rules.sort { $0.appName.localizedStandardCompare($1.appName) == .orderedAscending }
        }
        save()
    }

    func removeRule(for bundleID: String) {
        rules.removeAll { $0.bundleID == bundleID }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(rules) {
            defaults.set(data, forKey: Key.rules)
        }
    }
}
