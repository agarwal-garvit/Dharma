//
//  FinalThoughtsView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct FinalThoughtsView: View {
    let chapterIndex: Int
    let chapterTitle: String
    let score: Int
    let totalQuestions: Int
    let timeElapsed: TimeInterval
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var showPrayer = false
    @State private var showResults = false
    @State private var audioManager = AudioManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            // Audio player header
            audioHeader
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Chapter analysis
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Final Thoughts")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Chapter \(chapterIndex): \(chapterTitle)")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                    
                    // Analysis content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Deep Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Chapter analysis content will be loaded from the database...")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    // Key takeaways
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Takeaways")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Key takeaways will be loaded from the database...")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    // Application section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Application")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Daily application guidance will be loaded from the database...")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding()
            }
            
            // Close in prayer button
            VStack {
                Button(action: {
                    showPrayer = true
                }) {
                    HStack {
                        Image(systemName: "hands.clap.fill")
                        Text("Close in Prayer")
                    }
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
            .padding()
            .background(Color(.systemBackground))
            }
            .navigationTitle("Final Thoughts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        onDismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showPrayer) {
            PrayerView(
                chapterIndex: chapterIndex,
                chapterTitle: chapterTitle,
                onDismiss: { showPrayer = false },
                onComplete: { 
                    showPrayer = false
                    showResults = true
                }
            )
        }
        .fullScreenCover(isPresented: $showResults) {
            ResultsView(
                chapterIndex: chapterIndex,
                chapterTitle: chapterTitle,
                score: score,
                totalQuestions: totalQuestions,
                timeElapsed: timeElapsed,
                onDismiss: onDismiss,
                onComplete: onComplete
            )
        }
    }
    
    private var audioHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    // TODO: Implement actual audio playback
                    print("Audio playback placeholder - would play chapter \(chapterIndex) analysis")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("Listen to Analysis")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("2:45")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Audio progress bar
            VStack(spacing: 4) {
                ProgressView(value: 0.3, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .frame(height: 4)
                
                HStack {
                    Text("0:50")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("2:45")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
}

#Preview {
    FinalThoughtsView(
        chapterIndex: 2,
        chapterTitle: "Sankhya Yoga",
        score: 4,
        totalQuestions: 5,
        timeElapsed: 180,
        onDismiss: {},
        onComplete: {}
    )
}
