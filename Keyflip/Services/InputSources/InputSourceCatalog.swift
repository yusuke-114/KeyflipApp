//
//  InputSourceCatalog.swift
//  Keyflip
//

import Carbon
import Observation

/// Keeps the UI's view of enabled input sources and the current one up to date.
@Observable
final class InputSourceCatalog {
    private(set) var sources: [InputSource] = []
    private(set) var currentSourceID: String?

    private let provider: any InputSourceProviding
    @ObservationIgnored private var observers: [NSObjectProtocol] = []

    init(provider: any InputSourceProviding) {
        self.provider = provider
        refresh()
    }

    isolated deinit {
        observers.forEach(DistributedNotificationCenter.default().removeObserver)
    }

    var currentSourceName: String? {
        currentSourceID.flatMap(name(for:))
    }

    func name(for sourceID: String) -> String? {
        sources.first { $0.id == sourceID }?.name
    }

    func contains(_ sourceID: String) -> Bool {
        sources.contains { $0.id == sourceID }
    }

    func refresh() {
        sources = provider.enabledSources()
        currentSourceID = provider.currentSourceID()
    }

    /// Follows changes made anywhere: by Keyflip, the menu bar, or System Settings.
    func startObservingSystemChanges() {
        guard observers.isEmpty else { return }
        let center = DistributedNotificationCenter.default()
        let names: [CFString] = [
            kTISNotifySelectedKeyboardInputSourceChanged,
            kTISNotifyEnabledKeyboardInputSourcesChanged,
        ]
        observers = names.map { name in
            center.addObserver(forName: Notification.Name(name as String), object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.refresh()
                }
            }
        }
    }
}
