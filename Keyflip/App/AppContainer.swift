//
//  AppContainer.swift
//  Keyflip
//

import Foundation

/// Builds the object graph once at launch and starts automatic switching.
final class AppContainer {
    let mainViewModel: MainViewModel
    let menuBarViewModel: MenuBarViewModel

    private let workspace: SystemWorkspace
    private let switcher: AutoSwitcher

    init() {
        let provider = SystemInputSourceProvider()
        let store = RuleStore()
        let catalog = InputSourceCatalog(provider: provider)
        let workspace = SystemWorkspace()
        let switcher = AutoSwitcher(
            store: store,
            provider: provider,
            ownBundleID: Bundle.main.bundleIdentifier,
            indicator: InputSourceHUD()
        )

        mainViewModel = MainViewModel(
            store: store,
            catalog: catalog,
            switcher: switcher,
            launchAtLogin: LaunchAtLoginService(),
            workspace: workspace
        )
        menuBarViewModel = MenuBarViewModel(store: store, catalog: catalog, switcher: switcher)
        self.workspace = workspace
        self.switcher = switcher

        catalog.startObservingSystemChanges()
        workspace.onAppActivated = { [switcher] app in
            switcher.appDidActivate(app)
        }
        if let frontmost = workspace.frontmostApp {
            // The user didn't just move here, so there is nothing to announce.
            switcher.appDidActivate(frontmost, indicates: false)
        }
    }
}
