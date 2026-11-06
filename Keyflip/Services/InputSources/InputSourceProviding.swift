//
//  InputSourceProviding.swift
//  Keyflip
//

/// Reads and changes the system's keyboard input source.
protocol InputSourceProviding: AnyObject {
    /// Input sources that are enabled in System Settings and can be selected.
    func enabledSources() -> [InputSource]
    func currentSourceID() -> String?
    /// Returns `false` when the source is no longer enabled or the system refuses the change.
    @discardableResult
    func select(sourceID: String) -> Bool
}
