//
//  StatusDotGlowView.swift
//  CryptoApp
//

import SwiftUI

/// A status dot that pulses softly while `pulsing` is true (and Reduce Motion is off).
struct StatusDotGlowView: View {
    var color: Color = .green
    var pulsing = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    private var shouldPulse: Bool {
        pulsing && !reduceMotion
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(animate ? 1.2 : 1.0)
            .opacity(animate ? 0.7 : 1.0)
            .blur(radius: animate ? 0.8 : 0.2)
            .accessibilityHidden(true)
            .task(id: shouldPulse) {
                if shouldPulse {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        animate = true
                    }
                } else {
                    withAnimation(nil) { animate = false }
                }
            }
    }
}

#Preview {
    StatusDotGlowView()
}
