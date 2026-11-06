//
//  InputSource.swift
//  Keyflip
//

import Foundation

/// A keyboard input source the user can switch to, such as "ABC" or "Pinyin - Simplified".
nonisolated struct InputSource: Identifiable, Hashable, Sendable {
    /// The system identifier, e.g. `com.apple.keylayout.ABC`. Stable across launches.
    let id: String
    let name: String
}
