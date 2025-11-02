//
//  SacredTextView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SacredTextView: View {
    // Device detection for responsive design
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Adaptive spacing
    private var cardPadding: CGFloat {
        isPad ? 40 : 24
    }
    
    private var verticalSpacing: CGFloat {
        isPad ? 32 : 24
    }
    
    private var titleFontSize: CGFloat {
        isPad ? 40 : 32
    }
    
    private var bodyFontSize: CGFloat {
        isPad ? 20 : 18
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: isPad ? 40 : 20)
                        
                        // Main Content Card
                        VStack(spacing: verticalSpacing) {
                            // Coming Soon Badge at top
                            HStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(ThemeManager.primaryOrange)
                                        .font(isPad ? .title2 : .title3)
                                    
                                    Text("Coming Soon")
                                        .font(isPad ? .title2 : .title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ThemeManager.primaryOrange)
                                }
                                .padding(.horizontal, isPad ? 24 : 20)
                                .padding(.vertical, isPad ? 12 : 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(ThemeManager.primaryOrange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(ThemeManager.primaryOrange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                Spacer()
                            }
                            .padding(.top, isPad ? 32 : 24)
                            
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                ThemeManager.primaryOrange.opacity(0.2),
                                                ThemeManager.primaryOrange.opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: isPad ? 180 : 140, height: isPad ? 180 : 140)
                                    .shadow(color: ThemeManager.primaryOrange.opacity(0.3), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: "scroll.fill")
                                    .font(.system(size: isPad ? 80 : 60, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [ThemeManager.primaryOrange, ThemeManager.primaryOrange.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .padding(.vertical, isPad ? 20 : 16)
                            
                            // Title
                            VStack(spacing: 12) {
                                Text("Sacred Texts")
                                    .font(.system(size: titleFontSize, weight: .bold, design: .serif))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.primary, .primary.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Text("Complete access to sacred texts")
                                    .font(.system(size: bodyFontSize, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Divider()
                                .padding(.horizontal, isPad ? 40 : 32)
                                .padding(.vertical, isPad ? 16 : 12)
                            
                            // Sacred Texts List
                            VStack(alignment: .leading, spacing: isPad ? 20 : 16) {
                                Text("Including:")
                                    .font(.system(size: isPad ? 22 : 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, isPad ? 8 : 4)
                                
                                VStack(spacing: isPad ? 16 : 12) {
                                    ForEach(["Bhagavad Gita", "Mahabharata", "Ramayana", "Upanishads", "Vedas"], id: \.self) { text in
                                        HStack(spacing: 16) {
                                            Image(systemName: "book.closed.fill")
                                                .foregroundColor(ThemeManager.primaryOrange)
                                                .font(.system(size: isPad ? 18 : 16))
                                                .frame(width: isPad ? 24 : 20)
                                            
                                            Text(text)
                                                .font(.system(size: isPad ? 20 : 17, weight: .medium))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, isPad ? 20 : 16)
                                        .padding(.vertical, isPad ? 14 : 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, isPad ? 12 : 8)
                        }
                        .padding(cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: isPad ? 24 : 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: isPad ? 16 : 12, x: 0, y: isPad ? 8 : 6)
                        )
                        .padding(.horizontal, isPad ? 60 : 20)
                        .padding(.vertical, isPad ? 40 : 24)
                        
                        Spacer()
                            .frame(height: isPad ? 40 : 20)
                    }
                }
            }
            .navigationTitle("Texts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SacredTextView()
}
