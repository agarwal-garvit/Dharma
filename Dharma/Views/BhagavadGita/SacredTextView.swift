//
//  SacredTextView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SacredTextView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Coming Soon Icon with enhanced styling
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
                            .frame(width: 140, height: 140)
                            .shadow(color: ThemeManager.primaryOrange.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "scroll.fill")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeManager.primaryOrange, ThemeManager.primaryOrange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
                    
                    VStack(spacing: 20) {
                        Text("Sacred Texts")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 12) {
                            Text("Complete access to sacred texts")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(ThemeManager.primaryOrange)
                                    .font(.title3)
                                
                                Text("Coming Soon")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ThemeManager.primaryOrange)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(ThemeManager.primaryOrange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(ThemeManager.primaryOrange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Including:")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            ForEach(["Bhagavad Gita", "Mahabharata", "Ramayana", "Upanishads", "Vedas"], id: \.self) { text in
                                HStack(spacing: 12) {
                                    Image(systemName: "book.closed.fill")
                                        .foregroundColor(ThemeManager.primaryOrange)
                                        .font(.caption)
                                    
                                    Text(text)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Texts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SacredTextView()
}