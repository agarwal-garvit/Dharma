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
    @State private var countdownTimer: Timer?
    @State private var timeRemaining: TimeInterval = 0
    @State private var isTimerActive = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Lives")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(livesManager.currentLives) of 5")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Hearts Display
                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { lifeNumber in
                        Image(systemName: "heart.fill")
                            .font(.system(size: 32))
                            .foregroundColor(lifeNumber <= livesManager.currentLives ? .red : .gray.opacity(0.3))
                            .scaleEffect(lifeNumber <= livesManager.currentLives ? 1.0 : 0.8)
                            .animation(.easeInOut(duration: 0.3), value: livesManager.currentLives)
                    }
                }
                .padding(.bottom, 40)
                
                // Timer Section (only show if lives < 5)
                if livesManager.currentLives < 5 {
                    VStack(spacing: 12) {
                        Text("Next life in")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if isTimerActive && timeRemaining > 0 {
                            Text(formatTimeRemaining(timeRemaining))
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                        } else {
                            Text("Calculating...")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                
                // Unlimited lives message with enhanced styling
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow.opacity(0.3), Color.yellow.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unlimited Lives")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Premium version coming soon!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(ThemeManager.primaryOrange)
                            .font(.caption)
                        
                        Text("Stay tuned for updates")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(ThemeManager.primaryOrange)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.1), Color.yellow.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Reload note
                Text("If your lives aren't updating, try reloading the app")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                Spacer()
                
                // Close Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
        .onAppear {
            startCountdownTimer()
        }
        .onDisappear {
            stopCountdownTimer()
        }
    }
    
    // MARK: - Timer Management
    
    private func startCountdownTimer() {
        // Get initial time remaining
        if let timeInterval = livesManager.getTimeUntilNextLife() {
            timeRemaining = timeInterval
            isTimerActive = true
            
            // Start the countdown timer
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    // Timer reached zero, check for regeneration
                    Task {
                        await livesManager.checkAndRegenerateLives()
                        // Update time remaining with new value
                        if let newTimeInterval = livesManager.getTimeUntilNextLife() {
                            timeRemaining = newTimeInterval
                        } else {
                            isTimerActive = false
                        }
                    }
                }
            }
        } else {
            isTimerActive = false
        }
    }
    
    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        isTimerActive = false
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    LivesModalView()
}