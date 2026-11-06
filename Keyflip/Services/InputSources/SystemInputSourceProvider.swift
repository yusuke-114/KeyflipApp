//
//  SystemInputSourceProvider.swift
//  Keyflip
//

import Carbon

/// Talks to the Text Input Sources (TIS) API. Everything used here is public and sandbox-safe.
final class SystemInputSourceProvider: InputSourceProviding {
    func enabledSources() -> [InputSource] {
        sources(matching: [:]).compactMap(Self.makeInputSource)
    }

    func currentSourceID() -> String? {
        let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        return Self.property(of: source, key: kTISPropertyInputSourceID)
    }

    func select(sourceID: String) -> Bool {
        guard let source = sources(matching: [kTISPropertyInputSourceID as String: sourceID]).first else {
            return false
        }
        return TISSelectInputSource(source) == noErr
    }

    private func sources(matching extraFilter: [String: Any]) -> [TISInputSource] {
        var filter: [String: Any] = [
            kTISPropertyInputSourceCategory as String: kTISCategoryKeyboardInputSource as String,
            kTISPropertyInputSourceIsSelectCapable as String: true,
        ]
        filter.merge(extraFilter) { _, new in new }

        // `false`: only sources the user has enabled, not everything installed.
        guard let list = TISCreateInputSourceList(filter as CFDictionary, false)?.takeRetainedValue() else {
            return []
        }
        return (list as? [TISInputSource]) ?? []
    }

    nonisolated private static func makeInputSource(_ source: TISInputSource) -> InputSource? {
        guard
            let id: String = property(of: source, key: kTISPropertyInputSourceID),
            let name: String = property(of: source, key: kTISPropertyLocalizedName)
        else {
            return nil
        }
        return InputSource(id: id, name: name)
    }

    nonisolated private static func property<Value>(of source: TISInputSource, key: CFString) -> Value? {
        guard let raw = TISGetInputSourceProperty(source, key) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(raw).takeUnretainedValue() as? Value
    }
}
