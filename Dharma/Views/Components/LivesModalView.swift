//
//  LivesModalView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 10/22/25.
//

import SwiftUI

struct LivesModalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var livesManager = LivesManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Title
                    Text("Lives")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Hearts display (5 hearts in elegant grid)
                    VStack(spacing: 24) {
                        // Current lives count with better styling
                        Text("\(livesManager.currentLives) / 5")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Hearts in a nice arrangement
                        HStack(spacing: 20) {
                            ForEach(1...5, id: \.self) { lifeNumber in
                                VStack(spacing: 8) {
                                    ZStack {
                                        // Shadow/glow effect for active hearts
                                        if lifeNumber <= livesManager.currentLives {
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 44))
                                                .foregroundColor(.red.opacity(0.3))
                                                .blur(radius: 8)
                                        }
                                        
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 44))
                                            .foregroundColor(lifeNumber <= livesManager.currentLives ? .red : .gray.opacity(0.25))
                                        
                                        Text("\(lifeNumber)")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .offset(y: -1)
                                    }
                                }
                                .scaleEffect(lifeNumber <= livesManager.currentLives ? 1.0 : 0.9)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: livesManager.currentLives)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6).opacity(0.5))
                    )
                    
                    // Timer if lives < 5
                    if livesManager.currentLives < 5 {
                        VStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                    .font(.subheadline)
                                Text("Next life in:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let timeString = livesManager.getFormattedTimeUntilNextLife() {
                                Text(timeString)
                                    .font(.system(size: 52, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            } else {
                                Text("Calculating...")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    }
                    
                    // Information messages
                    VStack(spacing: 12) {
                        // Unlimited lives option message
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            Text("Unlimited lives OPTION coming soon!")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow.opacity(0.15), Color.yellow.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Reload app message
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue.opacity(0.7))
                                .font(.caption)
                            Text("If your lives aren't updating, try reloading the app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.06))
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Dismiss button
                    Button(action: {
                        dismiss()
                    }) {
                        Text(livesManager.currentLives == 0 ? "OK" : "Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: livesManager.currentLives == 0 
                                                ? [Color.gray, Color.gray.opacity(0.8)]
                                                : [Color.orange, Color.orange.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: (livesManager.currentLives == 0 ? Color.gray : Color.orange).opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.title3)
                    }
                }
            }
        }
    }
}

#Preview {
    LivesModalView()
}

