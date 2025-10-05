import SwiftUI

struct SigilView: View {
    let seed: String
    let status: AgentStatus
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse: Bool = false
    @State private var spawnScale: CGFloat = 0.8
    @State private var sparkleOpacity: Double = 0

    var body: some View {
        ZStack {
            Canvas { context, size in
                let hash = sha1(seed)
                var rng = DeterministicRNG(seed: hash)
                let baseHue = Double(rng.nextUInt() % 360) / 360.0
                let color = Color(hue: baseHue, saturation: 0.55, brightness: 0.85)

                // Background ring
                let rect = CGRect(origin: .zero, size: size)
                let circle = Path(ellipseIn: rect.insetBy(dx: 1, dy: 1))
                context.stroke(circle, with: .color(color.opacity(0.5)), lineWidth: 2)

                // Generate 5–7 orbiting arcs
                let count = 5 + Int(rng.nextUInt() % 3)
                for i in 0..<count {
                    let inset = CGFloat(3 + i * 3)
                    let start = Angle.degrees(Double(rng.nextUInt() % 360))
                    let span = Angle.degrees(Double(30 + rng.nextUInt() % 120))
                    var path = Path()
                    path.addArc(center: CGPoint(x: size.width/2, y: size.height/2),
                                radius: min(size.width, size.height)/2 - inset,
                                startAngle: start,
                                endAngle: start + span,
                                clockwise: false)
                    context.stroke(path, with: .color(color.opacity(0.6)), lineWidth: 1)
                }

                // Center glyph (triangles)
                let triangles = 3 + Int(rng.nextUInt() % 3)
                for t in 0..<triangles {
                    let angle = Double(t) / Double(triangles) * 2 * Double.pi
                    let r: CGFloat = min(size.width, size.height) * 0.18
                    let center = CGPoint(x: size.width/2 + CGFloat(cos(angle)) * r,
                                         y: size.height/2 + CGFloat(sin(angle)) * r)
                    var p = Path()
                    let s: CGFloat = 5
                    p.move(to: CGPoint(x: center.x, y: center.y - s))
                    p.addLine(to: CGPoint(x: center.x - s, y: center.y + s))
                    p.addLine(to: CGPoint(x: center.x + s, y: center.y + s))
                    p.closeSubpath()
                    context.fill(p, with: .color(color))
                }
            }
            .scaleEffect(spawnScale)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { spawnScale = 1.0 }
                } else {
                    spawnScale = 1.0
                }
            }

            if status == .working && !reduceMotion {
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 2)
                    .scaleEffect(pulse ? 1.05 : 0.95)
                    .blur(radius: 0.5)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)
                    .onAppear { pulse = true }
            }

            if status == .completed && !reduceMotion {
                StarSparkles().opacity(sparkleOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) { sparkleOpacity = 1 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeIn(duration: 0.4)) { sparkleOpacity = 0 }
                        }
                    }
            }
        }
        .frame(width: 28, height: 28)
    }

    private func sha1(_ text: String) -> Data {
        // Minimal SHA1 (public domain) adapted for Swift for deterministic seed only
        // Not for cryptographic use
        struct SHA1 {
            private var h0: UInt32 = 0x67452301
            private var h1: UInt32 = 0xEFCDAB89
            private var h2: UInt32 = 0x98BADCFE
            private var h3: UInt32 = 0x10325476
            private var h4: UInt32 = 0xC3D2E1F0
            mutating func update(_ data: [UInt8]) {
                var message = data
                let ml = UInt64(message.count * 8)
                message.append(0x80)
                while (message.count % 64) != 56 { message.append(0) }
                let mlBytes: [UInt8] = [
                    UInt8((ml >> 56) & 0xff), UInt8((ml >> 48) & 0xff), UInt8((ml >> 40) & 0xff), UInt8((ml >> 32) & 0xff),
                    UInt8((ml >> 24) & 0xff), UInt8((ml >> 16) & 0xff), UInt8((ml >> 8) & 0xff), UInt8(ml & 0xff)
                ]
                message.append(contentsOf: mlBytes)
                for chunkStart in stride(from: 0, to: message.count, by: 64) {
                    let chunk = Array(message[chunkStart..<chunkStart+64])
                    var w = [UInt32](repeating: 0, count: 80)
                    for i in 0..<16 {
                        let j = i*4
                        w[i] = (UInt32(chunk[j]) << 24) | (UInt32(chunk[j+1]) << 16) | (UInt32(chunk[j+2]) << 8) | UInt32(chunk[j+3])
                    }
                    for i in 16..<80 { w[i] = rotateLeft(w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16], by: 1) }
                    var a = h0, b = h1, c = h2, d = h3, e = h4
                    for i in 0..<80 {
                        var f: UInt32 = 0, k: UInt32 = 0
                        switch i {
                        case 0...19: f = (b & c) | ((~b) & d); k = 0x5A827999
                        case 20...39: f = b ^ c ^ d; k = 0x6ED9EBA1
                        case 40...59: f = (b & c) | (b & d) | (c & d); k = 0x8F1BBCDC
                        default: f = b ^ c ^ d; k = 0xCA62C1D6
                        }
                        let temp = rotateLeft(a, by: 5) &+ f &+ e &+ k &+ w[i]
                        e = d; d = c; c = rotateLeft(b, by: 30); b = a; a = temp
                    }
                    h0 &+= a; h1 &+= b; h2 &+= c; h3 &+= d; h4 &+= e
                }
            }
            private func rotateLeft(_ v: UInt32, by: UInt32) -> UInt32 { (v << by) | (v >> (32 - by)) }
            func digest() -> [UInt8] {
                [
                    UInt8((h0 >> 24) & 0xff), UInt8((h0 >> 16) & 0xff), UInt8((h0 >> 8) & 0xff), UInt8(h0 & 0xff),
                    UInt8((h1 >> 24) & 0xff), UInt8((h1 >> 16) & 0xff), UInt8((h1 >> 8) & 0xff), UInt8(h1 & 0xff),
                    UInt8((h2 >> 24) & 0xff), UInt8((h2 >> 16) & 0xff), UInt8((h2 >> 8) & 0xff), UInt8(h2 & 0xff),
                    UInt8((h3 >> 24) & 0xff), UInt8((h3 >> 16) & 0xff), UInt8((h3 >> 8) & 0xff), UInt8(h3 & 0xff),
                    UInt8((h4 >> 24) & 0xff), UInt8((h4 >> 16) & 0xff), UInt8((h4 >> 8) & 0xff), UInt8(h4 & 0xff)
                ]
            }
        }
        var s = SHA1()
        s.update(Array(text.utf8))
        return Data(s.digest())
    }
}

private struct StarSparkles: View {
    @State private var t: CGFloat = 0
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) / 6.0 * 2 * Double.pi
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 2, height: 6)
                    .offset(x: cos(angle) * 10, y: sin(angle) * 10)
                    .rotationEffect(.degrees(t * 360))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.8)) { t = 1 }
        }
    }
}

private struct DeterministicRNG {
    private var idx = 0
    private let bytes: [UInt8]
    init(seed: Data) { self.bytes = Array(seed) + Array(seed.reversed()) }
    mutating func nextUInt() -> UInt32 {
        guard !bytes.isEmpty else { return 0 }
        var v: UInt32 = 0
        for _ in 0..<4 {
            v = (v << 8) | UInt32(bytes[idx % bytes.count])
            idx += 1
        }
        return v
    }
}
