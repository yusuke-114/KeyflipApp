//
//  RuleStoreTests.swift
//  KeyflipTests
//

import Foundation
import Testing
@testable import Keyflip

struct RuleStoreTests {
    @Test func persistsRulesAndPreferences() {
        let defaults = makeDefaults()
        let store = RuleStore(defaults: defaults)
        store.setSource(InputSource.abc.id, for: .xcode)
        store.setSource(InputSource.pinyin.id, for: .wechat)
        store.isEnabled = false
        store.defaultSourceID = InputSource.kana.id
        store.showsIndicator = false

        let reloaded = RuleStore(defaults: defaults)
        #expect(reloaded.rules.map(\.bundleID) == [AppIdentity.wechat.bundleID, AppIdentity.xcode.bundleID])
        #expect(reloaded.rule(for: AppIdentity.wechat.bundleID)?.sourceID == InputSource.pinyin.id)
        #expect(reloaded.isEnabled == false)
        #expect(reloaded.defaultSourceID == InputSource.kana.id)
        #expect(reloaded.showsIndicator == false)
    }

    @Test func enabledByDefault() {
        let store = RuleStore(defaults: makeDefaults())
        #expect(store.isEnabled)
        #expect(store.showsIndicator)
    }

    @Test func settingSourceReplacesExistingRule() {
        let store = RuleStore(defaults: makeDefaults())
        store.setSource(InputSource.abc.id, for: .xcode)
        store.setSource(InputSource.pinyin.id, for: .xcode)
        #expect(store.rules.count == 1)
        #expect(store.rule(for: AppIdentity.xcode.bundleID)?.sourceID == InputSource.pinyin.id)
    }

    @Test func settingNilRemovesRule() {
        let store = RuleStore(defaults: makeDefaults())
        store.setSource(InputSource.abc.id, for: .xcode)
        store.setSource(nil, for: .xcode)
        #expect(store.rules.isEmpty)
    }

    @Test func targetFallsBackToDefault() {
        let store = RuleStore(defaults: makeDefaults())
        store.setSource(InputSource.abc.id, for: .xcode)
        #expect(store.targetSourceID(for: AppIdentity.wechat.bundleID) == nil)

        store.defaultSourceID = InputSource.pinyin.id
        #expect(store.targetSourceID(for: AppIdentity.xcode.bundleID) == InputSource.abc.id)
        #expect(store.targetSourceID(for: AppIdentity.wechat.bundleID) == InputSource.pinyin.id)
    }
}
