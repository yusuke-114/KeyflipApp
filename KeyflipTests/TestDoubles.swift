//
//  TestDoubles.swift
//  KeyflipTests
//

import AppKit
import Testing
@testable import Keyflip

final class FakeInputSourceProvider: InputSourceProviding {
    var sources: [InputSource]
    var currentID: String?
    private(set) var selections: [String] = []

    init(sources: [InputSource] = [.abc, .pinyin, .kana], currentID: String? = InputSource.abc.id) {
        self.sources = sources
        self.currentID = currentID
    }

    func enabledSources() -> [InputSource] { sources }

    func currentSourceID() -> String? { currentID }

    func select(sourceID: String) -> Bool {
        guard sources.contains(where: { $0.id == sourceID }) else { return false }
        selections.append(sourceID)
        currentID = sourceID
        return true
    }
}

final class FakeIndicator: InputSourceIndicating {
    private(set) var shown: [(source: InputSource, app: AppIdentity)] = []

    func show(_ source: InputSource, for app: AppIdentity) {
        shown.append((source, app))
    }
}

extension InputSource {
    static let abc = InputSource(id: "com.apple.keylayout.ABC", name: "ABC")
    static let pinyin = InputSource(id: "com.apple.inputmethod.SCIM.ITABC", name: "Pinyin - Simplified")
    static let kana = InputSource(id: "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese", name: "Hiragana")
}

extension AppIdentity {
    static let xcode = AppIdentity(bundleID: "com.apple.dt.Xcode", name: "Xcode")
    static let wechat = AppIdentity(bundleID: "com.tencent.xinWeChat", name: "WeChat")
    static let keyflip = AppIdentity(bundleID: "oneclick.keyflip.jp", name: "Keyflip")
}

final class FakeWorkspace: WorkspaceProviding {
    var runningApps: [AppIdentity] = []
    var appsByURL: [URL: AppIdentity] = [:]

    func icon(forBundleID bundleID: String) -> NSImage { NSImage() }

    func appIdentity(at url: URL) -> AppIdentity? { appsByURL[url] }
}

func makeDefaults() -> UserDefaults {
    let suite = "KeyflipTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}
