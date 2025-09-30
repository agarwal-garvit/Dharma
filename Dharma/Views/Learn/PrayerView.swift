//
//  PrayerView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct PrayerView: View {
    let chapterIndex: Int
    let chapterTitle: String
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var audioManager = AudioManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
                // Gau Mata logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Text("🐄")
                        .font(.system(size: 50))
                }
                
                // Prayer content
                VStack(spacing: 16) {
                    Text("Closing Prayer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Chapter \(chapterIndex): \(chapterTitle)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                // Prayer text
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Om Namo Bhagavate Vasudevaya")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Salutations to Lord Krishna, the son of Vasudeva")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        Text("Prayer content will be loaded from the database...")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                            .italic()
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        Text("Closing prayer will be loaded from the database...")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                // Audio and done buttons
                VStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Button(action: {
                            // TODO: Implement actual audio playback
                            print("Audio playback placeholder - would play prayer for chapter \(chapterIndex)")
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Listen to Prayer")
                            }
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Audio progress bar
                        VStack(spacing: 4) {
                            ProgressView(value: 0.0, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                .frame(height: 4)
                            
                            HStack {
                                Text("0:00")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("1:30")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: {
                        onComplete()
                    }) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
            }
    }
    
}

#Preview {
    PrayerView(
        chapterIndex: 2,
        chapterTitle: "Sankhya Yoga",
        onDismiss: {},
        onComplete: {}
    )
}
