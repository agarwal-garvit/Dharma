//
//  FinalThoughtsView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct FinalThoughtsView: View {
    let chapterIndex: Int
    let lessonTitle: String
    let score: Int
    let totalQuestions: Int
    let timeElapsed: TimeInterval
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var showPrayer = false
    @State private var audioManager = AudioManager.shared
    @State private var showingExitConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Chapter analysis
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Final Thoughts")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(lessonTitle)
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
                        showingExitConfirmation = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPrayer) {
            PrayerView(
                chapterIndex: chapterIndex,
                lessonTitle: lessonTitle,
                score: score,
                totalQuestions: totalQuestions,
                timeElapsed: timeElapsed,
                onDismiss: { showPrayer = false },
                onComplete: onComplete  // Direct pass-through, no complex logic
            )
        }
        .alert("Exit", isPresented: $showingExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                onComplete()
            }
        } message: {
            Text("Your progress will be lost. Are you sure you want to exit?")
        }
    }
    
    
}

#Preview {
    FinalThoughtsView(
        chapterIndex: 2,
        lessonTitle: "Sankhya Yoga",
        score: 4,
        totalQuestions: 5,
        timeElapsed: 180,
        onDismiss: {},
        onComplete: {}
    )
}
