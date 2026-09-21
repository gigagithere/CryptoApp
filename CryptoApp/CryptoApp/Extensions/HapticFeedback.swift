//
//  HapticFeedback.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import UIKit

enum HapticFeedback {
    enum Style {
        case light
        case medium 
        case heavy
    }
    
    static func impact(_ style: Style) {
        let generator: UIImpactFeedbackGenerator
        
        switch style {
        case .light:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .medium:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        }
        
        generator.impactOccurred()
    }
}