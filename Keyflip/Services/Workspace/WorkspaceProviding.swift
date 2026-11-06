//
//  WorkspaceProviding.swift
//  Keyflip
//

import AppKit

/// What Keyflip needs to know about other apps on the Mac.
protocol WorkspaceProviding: AnyObject {
    /// Regular apps that are running now, excluding Keyflip, sorted by name.
    var runningApps: [AppIdentity] { get }
    func icon(forBundleID bundleID: String) -> NSImage
    /// Reads the identity of an app bundle the user picked in a file dialog.
    func appIdentity(at url: URL) -> AppIdentity?
}
