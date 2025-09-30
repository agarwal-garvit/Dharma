//
//  ChapterSummaryView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ChapterSummaryView: View {
    let chapterIndex: Int
    let chapterTitle: String
    let onDismiss: () -> Void
    
    @State private var showQuiz = false
    @State private var audioManager = AudioManager.shared
    @State private var lessonStartTime = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Audio player header
                audioHeader
                
                // Summary content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Chapter header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Chapter \(chapterIndex)")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                            
                            Text(chapterTitle)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        // Summary content
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Summary")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                        Text("Chapter summary content will be loaded from the database...")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                            .italic()
                        }
                        
                        // Key concepts
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Concepts")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                        Text("Key concepts will be loaded from the database...")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                        }
                    }
                    .padding()
                }
                
                // Test mastery button
                VStack {
                    Button(action: {
                        showQuiz = true
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("Test My Mastery")
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
            .navigationTitle("Chapter \(chapterIndex)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        onDismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showQuiz) {
                QuizView(
                    chapterIndex: chapterIndex,
                    chapterTitle: chapterTitle,
                    lessonStartTime: lessonStartTime,
                    onDismiss: { showQuiz = false },
                    onComplete: { onDismiss() }
                )
            }
        }
    
    private var audioHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    // TODO: Implement actual audio playback
                    print("Audio playback placeholder - would play chapter \(chapterIndex) summary")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("Listen to Summary")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("3:20")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
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
                    
                    Text("3:20")
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
    ChapterSummaryView(
        chapterIndex: 2,
        chapterTitle: "Sankhya Yoga",
        onDismiss: {}
    )
}
