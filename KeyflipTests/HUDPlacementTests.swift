//
//  HUDPlacementTests.swift
//  KeyflipTests
//

import CoreGraphics
import Foundation
import Testing
@testable import Keyflip

struct HUDPlacementTests {
    let hud = CGSize(width: 200, height: 80)
    let screen = CGRect(x: 0, y: 0, width: 1600, height: 1000)

    func window(pid: pid_t, _ bounds: CGRect, layer: Int = 0, alpha: Double = 1) -> [String: Any] {
        [
            kCGWindowOwnerPID as String: pid,
            kCGWindowLayer as String: layer,
            kCGWindowAlpha as String: alpha,
            kCGWindowBounds as String: bounds.dictionaryRepresentation as NSDictionary,
        ]
    }

    @Test func picksFrontmostNormalWindowOfApp() {
        let main = CGRect(x: 100, y: 50, width: 800, height: 600)
        let list = [
            window(pid: 2, CGRect(x: 0, y: 0, width: 900, height: 700)),
            window(pid: 1, CGRect(x: 0, y: 0, width: 1600, height: 24), layer: 25),
            window(pid: 1, CGRect(x: 10, y: 10, width: 400, height: 300), alpha: 0),
            window(pid: 1, CGRect(x: 10, y: 10, width: 120, height: 60)),
            window(pid: 1, main),
            window(pid: 1, CGRect(x: 300, y: 300, width: 500, height: 400)),
        ]
        #expect(HUDPlacement.frontWindowBounds(of: 1, in: list) == main)
    }

    @Test func noWindowWhenAppHasNone() {
        let list = [window(pid: 2, CGRect(x: 0, y: 0, width: 900, height: 700))]
        #expect(HUDPlacement.frontWindowBounds(of: 1, in: list) == nil)
    }

    @Test func flipsToAppKitCoordinates() {
        let rect = HUDPlacement.appKitRect(
            fromWindowServer: CGRect(x: 100, y: 50, width: 800, height: 600),
            primaryScreenHeight: 1000
        )
        #expect(rect == CGRect(x: 100, y: 350, width: 800, height: 600))
    }

    @Test func centersAThirdOfTheWayUpTheWindow() {
        let window = CGRect(x: 100, y: 100, width: 800, height: 600)
        let origin = HUDPlacement.origin(for: hud, inWindow: window, on: screen)
        #expect(origin == CGPoint(x: 400, y: 260))
    }

    @Test func staysOnScreenWhenWindowHangsOffEdge() {
        let window = CGRect(x: -700, y: -500, width: 800, height: 600)
        let origin = HUDPlacement.origin(for: hud, inWindow: window, on: screen)
        #expect(origin == CGPoint(x: 0, y: 0))
    }

    @Test func fallsBackToBottomOfScreen() {
        let origin = HUDPlacement.origin(for: hud, onScreen: screen)
        #expect(origin == CGPoint(x: 700, y: 150))
    }
}
