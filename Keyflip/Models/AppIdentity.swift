//
//  AppIdentity.swift
//  Keyflip
//

import Foundation

/// An app, identified by bundle ID, with the name shown to the user.
nonisolated struct AppIdentity: Hashable, Sendable {
    let bundleID: String
    let name: String
}
