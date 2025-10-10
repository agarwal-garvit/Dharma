//
//  ThemeManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ThemeManager {
    // MARK: - Colors
    
    static let primaryOrange = Color(red: 0.956, green: 0.639, blue: 0.0) // #F4A300
    static let secondaryOrange = Color(red: 0.956, green: 0.639, blue: 0.0).opacity(0.1)
    static let accentBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let accentGreen = Color(red: 0.0, green: 0.784, blue: 0.325)
    static let accentRed = Color(red: 1.0, green: 0.231, blue: 0.188)
    static let accentPurple = Color(red: 0.686, green: 0.322, blue: 0.871)
    
    // Background color - #f0f5f8
    static let appBackground = Color(red: 240/255, green: 245/255, blue: 248/255)
    
    // MARK: - Typography
    
    static let verseFont = Font.system(.title2, design: .serif)
    static let translationFont = Font.system(.body, design: .default)
    static let commentaryFont = Font.system(.caption, design: .default).italic()
    
    // MARK: - Spacing
    
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // MARK: - Corner Radius
    
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 16
    static let extraLargeRadius: CGFloat = 20
    
    // MARK: - Shadows
    
    static let lightShadow = Color.black.opacity(0.1)
    static let mediumShadow = Color.black.opacity(0.15)
    static let heavyShadow = Color.black.opacity(0.2)
}

// MARK: - View Extensions

extension View {
    func dharmaCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.largeRadius)
                    .fill(Color(.systemBackground))
                    .shadow(color: ThemeManager.lightShadow, radius: 4, x: 0, y: 2)
            )
    }
    
    func dharmaButton() -> some View {
        self
            .padding(.horizontal, ThemeManager.mediumSpacing)
            .padding(.vertical, ThemeManager.smallSpacing)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.mediumRadius)
                    .fill(ThemeManager.primaryOrange)
            )
            .foregroundColor(.white)
            .font(.headline)
    }
    
    func dharmaSecondaryButton() -> some View {
        self
            .padding(.horizontal, ThemeManager.mediumSpacing)
            .padding(.vertical, ThemeManager.smallSpacing)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.mediumRadius)
                    .fill(ThemeManager.secondaryOrange)
            )
            .foregroundColor(ThemeManager.primaryOrange)
            .font(.headline)
    }
}

// MARK: - Animation Extensions

extension View {
    func dharmaAnimation() -> some View {
        self
            .animation(.easeInOut(duration: 0.3), value: UUID())
    }
    
    func dharmaSpringAnimation() -> some View {
        self
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: UUID())
    }
}

// MARK: - Haptic Extensions

extension View {
    func dharmaHaptic(_ type: HapticType = .light) -> some View {
        self
            .onTapGesture {
                switch type {
                case .light:
                    HapticManager.shared.lightImpact()
                case .medium:
                    HapticManager.shared.mediumImpact()
                case .heavy:
                    HapticManager.shared.heavyImpact()
                case .success:
                    HapticManager.shared.success()
                case .error:
                    HapticManager.shared.error()
                }
            }
    }
}

enum HapticType {
    case light, medium, heavy, success, error
}
