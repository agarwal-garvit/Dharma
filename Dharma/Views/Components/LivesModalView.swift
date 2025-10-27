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
                        
                        let timeString = livesManager.getFormattedTimeUntilNextLife()
                        if timeString != "00:00" {
                            Text(timeString)
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
                
                // Unlimited lives message
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    Text("Unlimited lives version coming soon!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
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
    }
}

#Preview {
    LivesModalView()
}