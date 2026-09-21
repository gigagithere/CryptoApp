//
//  StatusDotGlowView.swift
//  CryptoApp
//

import SwiftUI

/// A softly pulsing green dot.
struct StatusDotGlowView: View {
    @State private var animate = false

    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 8, height: 8)
            .scaleEffect(animate ? 1.2 : 1.0)
            .opacity(animate ? 0.7 : 1.0)
            .blur(radius: animate ? 0.8 : 0.2)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

#Preview {
    StatusDotGlowView()
}
