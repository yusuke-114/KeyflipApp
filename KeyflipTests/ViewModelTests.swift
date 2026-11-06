//
//  ViewModelTests.swift
//  KeyflipTests
//

import Foundation
import Testing
@testable import Keyflip

struct MainViewModelTests {
    let store = RuleStore(defaults: makeDefaults())
    let provider = FakeInputSourceProvider(currentID: InputSource.pinyin.id)
    let workspace = FakeWorkspace()

    func makeViewModel() -> (MainViewModel, AutoSwitcher) {
        let switcher = AutoSwitcher(store: store, provider: provider, ownBundleID: AppIdentity.keyflip.bundleID)
        let viewModel = MainViewModel(
            store: store,
            catalog: InputSourceCatalog(provider: provider),
            switcher: switcher,
            launchAtLogin: LaunchAtLoginService(),
            workspace: workspace
        )
        return (viewModel, switcher)
    }

    @Test func addUsesCurrentInputSource() {
        let (viewModel, _) = makeViewModel()
        viewModel.add(.wechat)
        #expect(viewModel.rules == [AppRule(bundleID: AppIdentity.wechat.bundleID, appName: "WeChat", sourceID: InputSource.pinyin.id)])
    }

    @Test func addableAppsExcludeAppsWithRules() {
        workspace.runningApps = [.wechat, .xcode]
        let (viewModel, _) = makeViewModel()
        viewModel.add(.xcode)
        #expect(viewModel.addableApps == [.wechat])
    }

    @Test func addAppAtURLResolvesIdentity() {
        let url = URL(filePath: "/Applications/Xcode.app")
        workspace.appsByURL[url] = .xcode
        let (viewModel, _) = makeViewModel()

        viewModel.addApp(at: url)
        viewModel.addApp(at: URL(filePath: "/Applications/Unknown.app"))

        #expect(viewModel.rules.map(\.bundleID) == [AppIdentity.xcode.bundleID])
    }

    @Test func changingFrontmostRuleSwitchesImmediately() {
        let (viewModel, switcher) = makeViewModel()
        viewModel.add(.xcode)
        switcher.appDidActivate(.xcode)

        viewModel.setSource(InputSource.abc.id, for: viewModel.rules[0])

        #expect(provider.selections == [InputSource.abc.id])
    }

    @Test func removeDeletesRule() {
        let (viewModel, _) = makeViewModel()
        viewModel.add(.xcode)
        viewModel.remove(viewModel.rules[0])
        #expect(viewModel.rules.isEmpty)
    }

    @Test func settingsWriteThroughToStore() {
        let (viewModel, _) = makeViewModel()
        viewModel.isEnabled = false
        viewModel.defaultSourceID = InputSource.kana.id
        viewModel.showsIndicator = false
        #expect(store.isEnabled == false)
        #expect(store.defaultSourceID == InputSource.kana.id)
        #expect(store.showsIndicator == false)
    }

    @Test func changingDefaultSwitchesFrontmostAppWithoutRule() {
        let (viewModel, switcher) = makeViewModel()
        switcher.appDidActivate(.wechat)

        viewModel.defaultSourceID = InputSource.kana.id

        #expect(provider.selections == [InputSource.kana.id])
    }

    @Test func reenablingSwitchesImmediately() {
        let (viewModel, switcher) = makeViewModel()
        viewModel.isEnabled = false
        viewModel.add(.xcode)
        viewModel.setSource(InputSource.abc.id, for: viewModel.rules[0])
        switcher.appDidActivate(.xcode)
        #expect(provider.selections.isEmpty)

        viewModel.isEnabled = true

        #expect(provider.selections == [InputSource.abc.id])
    }

    @Test func flagsUnavailableSources() {
        let (viewModel, _) = makeViewModel()
        #expect(viewModel.isAvailable(InputSource.abc.id))
        #expect(!viewModel.isAvailable("com.example.removed"))
    }
}

struct MenuBarViewModelTests {
    let store = RuleStore(defaults: makeDefaults())
    let provider = FakeInputSourceProvider()

    func makeViewModel() -> (MenuBarViewModel, AutoSwitcher) {
        let switcher = AutoSwitcher(store: store, provider: provider, ownBundleID: AppIdentity.keyflip.bundleID)
        let viewModel = MenuBarViewModel(store: store, catalog: InputSourceCatalog(provider: provider), switcher: switcher)
        return (viewModel, switcher)
    }

    @Test func showsNothingBeforeAnyAppActivates() {
        let (viewModel, _) = makeViewModel()
        #expect(viewModel.frontmostAppName == nil)
        #expect(viewModel.frontmostAppSourceID == nil)
    }

    @Test func assigningSourceCreatesRuleAndSwitches() {
        let (viewModel, switcher) = makeViewModel()
        switcher.appDidActivate(.wechat)

        viewModel.frontmostAppSourceID = InputSource.pinyin.id

        #expect(viewModel.frontmostAppName == "WeChat")
        #expect(store.rule(for: AppIdentity.wechat.bundleID)?.sourceID == InputSource.pinyin.id)
        #expect(provider.selections == [InputSource.pinyin.id])
    }

    @Test func clearingSourceRemovesRule() {
        let (viewModel, switcher) = makeViewModel()
        switcher.appDidActivate(.wechat)
        viewModel.frontmostAppSourceID = InputSource.pinyin.id

        viewModel.frontmostAppSourceID = nil

        #expect(store.rules.isEmpty)
    }

    @Test func flagsUnavailableSources() {
        let (viewModel, _) = makeViewModel()
        #expect(viewModel.isAvailable(InputSource.abc.id))
        #expect(!viewModel.isAvailable("com.example.removed"))
    }

    @Test func reenablingSwitchesImmediately() {
        let (viewModel, switcher) = makeViewModel()
        store.isEnabled = false
        store.setSource(InputSource.pinyin.id, for: .wechat)
        switcher.appDidActivate(.wechat)

        viewModel.isEnabled = true

        #expect(provider.selections == [InputSource.pinyin.id])
    }
}
