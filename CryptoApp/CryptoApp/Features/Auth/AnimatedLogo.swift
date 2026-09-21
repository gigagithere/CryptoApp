//
//  AnimatedLogo.swift
//  CryptoApp
//

import SwiftUI

/// The app logo: floats gently, and spins when tapped.
struct AnimatedLogo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floatOffset: CGFloat = 0
    @State private var rotationAngle: CGFloat = 0

    var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.7)) {
                rotationAngle += 360
            }
        } label: {
            Image("logo")
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 40))
                .frame(width: 180, height: 180)
                .shadow(color: .gray, radius: 10, x: 7, y: 10)
        }
        .buttonStyle(.plain)
        .offset(y: floatOffset)
        .rotationEffect(.degrees(rotationAngle))
        .accessibilityLabel("App logo")
        .onAppear {
            guard !reduceMotion else { return } // no endless floating for people who turned motion down
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                floatOffset = -10
            }
        }
    }
}

#Preview {
    AnimatedLogo()
}
