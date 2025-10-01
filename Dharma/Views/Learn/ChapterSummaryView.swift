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
    @State private var showingExitConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
            }
            .navigationTitle("Chapter \(chapterIndex)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        showingExitConfirmation = true
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Force full screen on all devices
            .onAppear {
                print("ChapterSummaryView appeared for Chapter \(chapterIndex)")
            }
            .alert("Exit", isPresented: $showingExitConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Exit", role: .destructive) {
                    onDismiss()
                }
            } message: {
                Text("Your progress will be lost. Are you sure you want to exit?")
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
    
}

#Preview {
    ChapterSummaryView(
        chapterIndex: 2,
        chapterTitle: "Sankhya Yoga",
        onDismiss: {}
    )
}
