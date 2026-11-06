//
//  AutoSwitcherTests.swift
//  KeyflipTests
//

import Foundation
import Testing
@testable import Keyflip

struct AutoSwitcherTests {
    let store = RuleStore(defaults: makeDefaults())
    let provider = FakeInputSourceProvider()
    let indicator = FakeIndicator()

    func makeSwitcher() -> AutoSwitcher {
        AutoSwitcher(store: store, provider: provider, ownBundleID: AppIdentity.keyflip.bundleID, indicator: indicator)
    }

    @Test func switchesToRuleSource() {
        store.setSource(InputSource.pinyin.id, for: .wechat)
        let switcher = makeSwitcher()

        switcher.appDidActivate(.wechat)

        #expect(provider.selections == [InputSource.pinyin.id])
        #expect(switcher.frontmostApp == .wechat)
    }

    @Test func skipsWhenAlreadyOnTarget() {
        store.setSource(InputSource.abc.id, for: .xcode)
        makeSwitcher().appDidActivate(.xcode)
        #expect(provider.selections.isEmpty)
    }

    @Test func keepsCurrentSourceWithoutRuleOrDefault() {
        makeSwitcher().appDidActivate(.wechat)
        #expect(provider.selections.isEmpty)
    }

    @Test func usesDefaultForAppsWithoutRule() {
        store.defaultSourceID = InputSource.kana.id
        makeSwitcher().appDidActivate(.wechat)
        #expect(provider.selections == [InputSource.kana.id])
    }

    @Test func doesNothingWhenDisabled() {
        store.setSource(InputSource.pinyin.id, for: .wechat)
        store.isEnabled = false
        let switcher = makeSwitcher()

        switcher.appDidActivate(.wechat)

        #expect(provider.selections.isEmpty)
        #expect(switcher.frontmostApp == .wechat)
    }

    @Test func ignoresOwnActivation() {
        store.defaultSourceID = InputSource.kana.id
        let switcher = makeSwitcher()
        switcher.appDidActivate(.xcode)
        provider.currentID = InputSource.abc.id

        switcher.appDidActivate(.keyflip)

        #expect(provider.selections == [InputSource.kana.id])
        #expect(switcher.frontmostApp == .xcode)
    }

    @Test func reapplyUsesUpdatedRule() {
        let switcher = makeSwitcher()
        switcher.appDidActivate(.wechat)

        store.setSource(InputSource.pinyin.id, for: .wechat)
        switcher.reapply()

        #expect(provider.selections == [InputSource.pinyin.id])
    }

    @Test func toleratesDisabledSource() {
        store.setSource("com.example.removed", for: .wechat)
        makeSwitcher().appDidActivate(.wechat)
        #expect(provider.selections.isEmpty)
        #expect(provider.currentID == InputSource.abc.id)
    }

    // MARK: - Indicator

    @Test func indicatesNewSourceAfterSwitching() {
        store.setSource(InputSource.pinyin.id, for: .wechat)
        makeSwitcher().appDidActivate(.wechat)

        #expect(indicator.shown.map(\.source) == [.pinyin])
        #expect(indicator.shown.map(\.app) == [.wechat])
    }

    @Test func indicatesCurrentSourceWithoutSwitching() {
        store.setSource(InputSource.abc.id, for: .xcode)
        makeSwitcher().appDidActivate(.xcode)
        #expect(indicator.shown.map(\.source) == [.abc])
    }

    @Test func indicatesDefaultSourceForAppsWithoutRule() {
        store.defaultSourceID = InputSource.kana.id
        makeSwitcher().appDidActivate(.wechat)
        #expect(indicator.shown.map(\.source) == [.kana])
    }

    @Test func noIndicatorWithoutRuleOrDefault() {
        makeSwitcher().appDidActivate(.wechat)
        #expect(indicator.shown.isEmpty)
    }

    @Test func noIndicatorWhenSwitchingIsOff() {
        store.setSource(InputSource.pinyin.id, for: .wechat)
        store.isEnabled = false
        makeSwitcher().appDidActivate(.wechat)
        #expect(indicator.shown.isEmpty)
    }

    @Test func indicatesCurrentSourceWhenTargetIsUnavailable() {
        store.setSource("com.example.removed", for: .wechat)
        makeSwitcher().appDidActivate(.wechat)
        #expect(indicator.shown.map(\.source) == [.abc])
    }

    @Test func silentActivationSwitchesWithoutIndicator() {
        store.setSource(InputSource.pinyin.id, for: .wechat)
        makeSwitcher().appDidActivate(.wechat, indicates: false)
        #expect(provider.selections == [InputSource.pinyin.id])
        #expect(indicator.shown.isEmpty)
    }

    @Test func noIndicatorWhenTurnedOff() {
        store.setSource(InputSource.pinyin.id, for: .wechat)
        store.showsIndicator = false
        makeSwitcher().appDidActivate(.wechat)
        #expect(indicator.shown.isEmpty)
    }

    @Test func noIndicatorForOwnActivationOrReapply() {
        let switcher = makeSwitcher()
        switcher.appDidActivate(.keyflip)
        #expect(indicator.shown.isEmpty)

        store.setSource(InputSource.pinyin.id, for: .wechat)
        switcher.appDidActivate(.wechat)
        store.setSource(InputSource.kana.id, for: .wechat)
        switcher.reapply()

        #expect(indicator.shown.count == 1)
    }
}
