//
//  AppRule.swift
//  Keyflip
//

import Foundation

/// "When this app becomes active, switch to this input source."
nonisolated struct AppRule: Codable, Identifiable, Hashable, Sendable {
    let bundleID: String
    var appName: String
    var sourceID: String

    var id: String { bundleID }

    var app: AppIdentity {
        AppIdentity(bundleID: bundleID, name: appName)
    }
}
