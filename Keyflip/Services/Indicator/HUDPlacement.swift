//
//  HUDPlacement.swift
//  Keyflip
//

import CoreGraphics
import Foundation

/// Where the input source HUD goes: inside the window the user just moved to,
/// or near the bottom of the screen when that app has no visible window.
nonisolated enum HUDPlacement {
    /// Smaller windows are palettes or helper windows, not where the user works.
    static let minimumWindowSize = CGSize(width: 200, height: 120)

    /// The frontmost normal window of `pid`, in window server coordinates (top-left origin).
    /// `windowList` is front to back, as returned by `CGWindowListCopyWindowInfo`, which
    /// provides window bounds without the Screen Recording permission.
    static func frontWindowBounds(of pid: pid_t, in windowList: [[String: Any]]) -> CGRect? {
        windowList.lazy
            .filter { info in
                info[kCGWindowOwnerPID as String] as? pid_t == pid
                    && info[kCGWindowLayer as String] as? Int == 0
                    && (info[kCGWindowAlpha as String] as? Double ?? 1) > 0
            }
            .compactMap { info -> CGRect? in
                guard let dictionary = info[kCGWindowBounds as String] as? NSDictionary else { return nil }
                return CGRect(dictionaryRepresentation: dictionary as CFDictionary)
            }
            .first { $0.width >= minimumWindowSize.width && $0.height >= minimumWindowSize.height }
    }

    /// Converts from the window server's top-left origin to AppKit's bottom-left origin,
    /// both measured from the primary screen.
    static func appKitRect(fromWindowServer rect: CGRect, primaryScreenHeight: CGFloat) -> CGRect {
        CGRect(x: rect.minX, y: primaryScreenHeight - rect.maxY, width: rect.width, height: rect.height)
    }

    /// Centered a third of the way up the window: visible without covering the
    /// middle, where the user is likely reading or typing. Kept on `screen` even
    /// when the window hangs off its edge.
    static func origin(for size: CGSize, inWindow window: CGRect, on screen: CGRect) -> CGPoint {
        let x = window.midX - size.width / 2
        let y = window.minY + window.height / 3 - size.height / 2
        return CGPoint(
            x: min(max(x, screen.minX), screen.maxX - size.width),
            y: min(max(y, screen.minY), screen.maxY - size.height)
        )
    }

    static func origin(for size: CGSize, onScreen screen: CGRect) -> CGPoint {
        CGPoint(x: screen.midX - size.width / 2, y: screen.minY + screen.height * 0.15)
    }
}
