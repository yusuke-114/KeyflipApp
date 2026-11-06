// Renders the 1024×1024 app icon master. The shipped icon uses the whiteTool palette.
// Usage: swift Design/AppIcon.swift AppIcon-1024.png whiteTool

import SwiftUI
import AppKit

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

struct Keycap: View {
    let glyph: String
    let font: Font
    let colors: [Color]
    let sideColor: Color
    var glyphColor: Color = .white
    var shadowOpacity: Double = 0.45
    var shadowRadius: CGFloat = 44
    var body: some View {
        ZStack {
            // Side of the key, visible below the top surface
            RoundedRectangle(cornerRadius: 96, style: .continuous)
                .fill(sideColor)
                .offset(y: 26)
            RoundedRectangle(cornerRadius: 96, style: .continuous)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 96, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [.white.opacity(0.75), .white.opacity(0.1)], startPoint: .top, endPoint: .bottom), lineWidth: 4)
                )
            // Dished top face
            RoundedRectangle(cornerRadius: 72, style: .continuous)
                .fill(LinearGradient(colors: [.white.opacity(0.22), .white.opacity(0.0)], startPoint: .top, endPoint: .bottom))
                .overlay(
                    RoundedRectangle(cornerRadius: 72, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [.white.opacity(0.45), .white.opacity(0.05)], startPoint: .top, endPoint: .bottom), lineWidth: 3)
                )
                .padding(40)
            Text(glyph)
                .font(font)
                .foregroundStyle(glyphColor)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 4)
        }
        .frame(width: 410, height: 410)
        .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: shadowRadius * 0.7)
    }
}

/// A round-capped arc with an arrowhead at its end.
struct FlipArrow: Shape {
    let start: Angle, end: Angle, radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.addArc(center: c, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        return p
    }
}

struct ArrowHead: Shape {
    let at: Angle, radius: CGFloat, size: CGFloat
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let a = at.radians
        let tip0 = CGPoint(x: c.x + radius * cos(a), y: c.y + radius * sin(a))
        // Tangent direction for counter-clockwise-on-screen travel (increasing angle).
        let t = CGPoint(x: -sin(a), y: cos(a))
        let n = CGPoint(x: cos(a), y: sin(a))
        let tip = CGPoint(x: tip0.x + t.x * size * 0.9, y: tip0.y + t.y * size * 0.9)
        let l = CGPoint(x: tip0.x + n.x * size * 0.75, y: tip0.y + n.y * size * 0.75)
        let r = CGPoint(x: tip0.x - n.x * size * 0.75, y: tip0.y - n.y * size * 0.75)
        var p = Path()
        p.move(to: tip); p.addLine(to: l); p.addLine(to: r); p.closeSubpath()
        return p
    }
}

struct DotGrid: Shape {
    let spacing: CGFloat, dotSize: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        var y = spacing / 2
        while y < rect.height {
            var x = spacing / 2
            while x < rect.width {
                p.addEllipse(in: CGRect(x: x - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize))
                x += spacing
            }
            y += spacing
        }
        return p
    }
}

struct Palette {
    let background: [Color]
    let glow: Color
    let glowCenter: UnitPoint
    let backKey: [Color], backSide: Color, backGlyph: Color
    let frontKey: [Color], frontSide: Color, frontGlyph: Color
    let arrow: Color
    var shadowOpacity: Double = 0.45
    var glowOpacity: Double = 0.45
    var showsGrid = false
    var shadowRadius: CGFloat = 44
}

extension Palette {
    static let blue = Palette(
        background: [Color(hex: 0x030B1F), Color(hex: 0x07235C), Color(hex: 0x0A4DB3)],
        glow: Color(hex: 0x2FD1FF), glowCenter: UnitPoint(x: 0.8, y: 0.85),
        backKey: [Color(hex: 0x3A5F9E), Color(hex: 0x1C3566)], backSide: Color(hex: 0x0E1E40), backGlyph: .white.opacity(0.9),
        frontKey: [Color(hex: 0x38E1FF), Color(hex: 0x1F6BFF)], frontSide: Color(hex: 0x123D9C), frontGlyph: .white,
        arrow: Color(hex: 0xBFF4FF))
    static let green = Palette(
        background: [Color(hex: 0x021410), Color(hex: 0x053B2D), Color(hex: 0x087A55)],
        glow: Color(hex: 0x4DFFB0), glowCenter: UnitPoint(x: 0.8, y: 0.85),
        backKey: [Color(hex: 0x2F6B58), Color(hex: 0x163D32)], backSide: Color(hex: 0x0A241D), backGlyph: .white.opacity(0.9),
        frontKey: [Color(hex: 0xB8FF5C), Color(hex: 0x22D98E)], frontSide: Color(hex: 0x0F8A5A), frontGlyph: Color(hex: 0x05281D),
        arrow: Color(hex: 0xD6FFE9))
    static let yellow = Palette(
        background: [Color(hex: 0x0E0D0B), Color(hex: 0x1F1B14), Color(hex: 0x3A2F12)],
        glow: Color(hex: 0xFFC83D), glowCenter: UnitPoint(x: 0.8, y: 0.85),
        backKey: [Color(hex: 0x4A4640), Color(hex: 0x26241F)], backSide: Color(hex: 0x151411), backGlyph: .white.opacity(0.9),
        frontKey: [Color(hex: 0xFFE45C), Color(hex: 0xFFA21F)], frontSide: Color(hex: 0xB86A0A), frontGlyph: Color(hex: 0x2A1B02),
        arrow: Color(hex: 0xFFF1C2))
    static let yellowFill = Palette(
        background: [Color(hex: 0xFFE66B), Color(hex: 0xFFC93A), Color(hex: 0xFFA51F)],
        glow: .white, glowCenter: UnitPoint(x: 0.2, y: 0.15),
        backKey: [Color(hex: 0xFFFFFF).opacity(0.85), Color(hex: 0xFFF3D1).opacity(0.7)], backSide: Color(hex: 0xE0A21C), backGlyph: Color(hex: 0x2A1B02),
        frontKey: [Color(hex: 0x2B2822), Color(hex: 0x12110E)], frontSide: Color(hex: 0x000000), frontGlyph: Color(hex: 0xFFD23F),
        arrow: Color(hex: 0x2A1B02), shadowOpacity: 0.28, glowOpacity: 0.5)
    static let whiteTool = Palette(
        background: [Color(hex: 0xFFFFFF), Color(hex: 0xF7F7F9), Color(hex: 0xEDEEF2)],
        glow: .clear, glowCenter: .center,
        backKey: [Color(hex: 0x3A3A40), Color(hex: 0x18181B)], backSide: Color(hex: 0x050506), backGlyph: .white,
        frontKey: [Color(hex: 0xFFE14D), Color(hex: 0xFFB319)], frontSide: Color(hex: 0xD98A0B), frontGlyph: Color(hex: 0x17130A),
        arrow: Color(hex: 0x18181B), shadowOpacity: 0.22, glowOpacity: 0, showsGrid: true, shadowRadius: 24)
    static let whiteToolPlain = Palette(
        background: [Color(hex: 0xFFFFFF), Color(hex: 0xF7F7F9), Color(hex: 0xEDEEF2)],
        glow: .clear, glowCenter: .center,
        backKey: [Color(hex: 0x3A3A40), Color(hex: 0x18181B)], backSide: Color(hex: 0x050506), backGlyph: .white,
        frontKey: [Color(hex: 0xFFE14D), Color(hex: 0xFFB319)], frontSide: Color(hex: 0xD98A0B), frontGlyph: Color(hex: 0x17130A),
        arrow: Color(hex: 0x18181B), shadowOpacity: 0.22, glowOpacity: 0, shadowRadius: 24)
    static let white = Palette(
        background: [Color(hex: 0xFFFFFF), Color(hex: 0xF6F6F8), Color(hex: 0xE9E9EE)],
        glow: Color(hex: 0xFFD23F), glowCenter: UnitPoint(x: 0.75, y: 0.8),
        backKey: [Color(hex: 0xFBFBFD), Color(hex: 0xE4E4EA)], backSide: Color(hex: 0xC9C9D2), backGlyph: Color(hex: 0x3A3A40),
        frontKey: [Color(hex: 0xFFE45C), Color(hex: 0xFFA21F)], frontSide: Color(hex: 0xD9820B), frontGlyph: Color(hex: 0x2A1B02),
        arrow: Color(hex: 0x2C2C30), shadowOpacity: 0.16, glowOpacity: 0.18)
}

struct Icon: View {
    let palette: Palette
    var body: some View {
        ZStack {
            LinearGradient(colors: palette.background, startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [palette.glow.opacity(palette.glowOpacity), .clear], center: palette.glowCenter, startRadius: 0, endRadius: 560)
            if palette.showsGrid {
                DotGrid(spacing: 48, dotSize: 5)
                    .fill(Color(hex: 0x18181B).opacity(0.09))
                    .mask(RadialGradient(colors: [.black, .black.opacity(0.15)], center: .center, startRadius: 150, endRadius: 720))
            }

            let r: CGFloat = 395
            ZStack {
                FlipArrow(start: .degrees(200), end: .degrees(262), radius: r)
                    .stroke(palette.arrow, style: StrokeStyle(lineWidth: palette.glowOpacity == 0 ? 36 : 30, lineCap: .round))
                ArrowHead(at: .degrees(262), radius: r, size: palette.glowOpacity == 0 ? 46 : 40).fill(palette.arrow)
                FlipArrow(start: .degrees(20), end: .degrees(82), radius: r)
                    .stroke(palette.arrow, style: StrokeStyle(lineWidth: palette.glowOpacity == 0 ? 36 : 30, lineCap: .round))
                ArrowHead(at: .degrees(82), radius: r, size: palette.glowOpacity == 0 ? 46 : 40).fill(palette.arrow)
            }
            .shadow(color: .black.opacity(palette.shadowOpacity * 0.6), radius: 14, y: 8)

            Keycap(glyph: "A", font: .system(size: 215, weight: .semibold, design: .rounded),
                   colors: palette.backKey, sideColor: palette.backSide, glyphColor: palette.backGlyph,
                   shadowOpacity: palette.shadowOpacity, shadowRadius: palette.shadowRadius)
                .rotationEffect(.degrees(-12))
                .offset(x: -118, y: -112)
            Keycap(glyph: "文", font: .custom("PingFangSC-Semibold", size: 215),
                   colors: palette.frontKey, sideColor: palette.frontSide, glyphColor: palette.frontGlyph,
                   shadowOpacity: palette.shadowOpacity, shadowRadius: palette.shadowRadius)
                .rotationEffect(.degrees(7))
                .offset(x: 112, y: 118)
                .shadow(color: palette.glow.opacity(palette.glowOpacity * 0.8), radius: 60)
        }
        .frame(width: 1024, height: 1024)
    }
}

MainActor.assumeIsolated {
    let palettes: [String: Palette] = ["blue": .blue, "green": .green, "yellow": .yellow, "yellowFill": .yellowFill, "white": .white, "whiteTool": .whiteTool, "whiteToolPlain": .whiteToolPlain]
    let name = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "whiteTool"
    let renderer = ImageRenderer(content: Icon(palette: palettes[name]!))
    renderer.scale = 1
    let rep = NSBitmapImageRep(cgImage: renderer.cgImage!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(filePath: CommandLine.arguments[1]))
}
