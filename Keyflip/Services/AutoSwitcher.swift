//
//  AutoSwitcher.swift
//  Keyflip
//

import Observation
import os

/// Switches the input source whenever another app becomes active.
@Observable
final class AutoSwitcher {
    /// The most recently activated app other than Keyflip itself. The menu offers
    /// to assign an input source to it.
    private(set) var frontmostApp: AppIdentity?

    @ObservationIgnored private let store: RuleStore
    @ObservationIgnored private let provider: any InputSourceProviding
    @ObservationIgnored private let ownBundleID: String?
    @ObservationIgnored private let indicator: (any InputSourceIndicating)?
    @ObservationIgnored private let logger = Logger(subsystem: "oneclick.keyflip.jp", category: "switching")

    init(
        store: RuleStore,
        provider: any InputSourceProviding,
        ownBundleID: String?,
        indicator: (any InputSourceIndicating)? = nil
    ) {
        self.store = store
        self.provider = provider
        self.ownBundleID = ownBundleID
        self.indicator = indicator
    }

    /// Pass `indicates: false` to switch silently, e.g. for the app already frontmost at launch.
    func appDidActivate(_ app: AppIdentity, indicates: Bool = true) {
        // Opening Keyflip's own window must not disturb the input source or
        // make the menu forget which app the user came from.
        guard app.bundleID != ownBundleID else { return }
        frontmostApp = app
        let sourceID = apply(for: app)
        // Only speak up for apps Keyflip manages; otherwise stay out of the way.
        if indicates, manages(app) {
            showIndicator(for: sourceID, in: app)
        }
    }

    /// Applies the rule again for the frontmost app, e.g. right after the user changes it.
    func reapply() {
        guard let frontmostApp else { return }
        apply(for: frontmostApp)
    }

    private func manages(_ app: AppIdentity) -> Bool {
        store.isEnabled && store.targetSourceID(for: app.bundleID) != nil
    }

    /// Returns the input source in use afterwards, whether or not it changed.
    @discardableResult
    private func apply(for app: AppIdentity) -> String? {
        let current = provider.currentSourceID()
        guard store.isEnabled, let target = store.targetSourceID(for: app.bundleID), current != target else {
            return current
        }

        if provider.select(sourceID: target) {
            logger.info("\(app.bundleID, privacy: .public): \(current ?? "nil", privacy: .public) -> \(target, privacy: .public)")
            return target
        } else {
            logger.error("\(app.bundleID, privacy: .public): could not select \(target, privacy: .public)")
            return current
        }
    }

    private func showIndicator(for sourceID: String?, in app: AppIdentity) {
        guard
            store.showsIndicator,
            let indicator,
            let sourceID,
            let source = provider.enabledSources().first(where: { $0.id == sourceID })
        else {
            return
        }
        indicator.show(source, for: app)
    }
}
