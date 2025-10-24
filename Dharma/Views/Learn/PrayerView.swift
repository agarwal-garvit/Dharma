//
//  PrayerView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct PrayerView: View {
    let lesson: DBLesson
    let lessonTitle: String
    let score: Int
    let totalQuestions: Int
    let timeElapsed: TimeInterval
    let lessonStartTime: Date
    let questionsAnswered: [String: Any]?
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var audioManager = AudioManager.shared
    @State private var showResults = false
    @State private var dataManager = DataManager.shared
    @State private var isLoading = true
    @State private var shlokaContent: ShlokaContent?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ScrollView {
                VStack(spacing: 32) {
                    // Header with decorative elements
                    VStack(spacing: 16) {
                        // Decorative circle with Om symbol
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Text("ॐ")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Closing Shloka")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(lessonTitle)
                                .font(.headline)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Shloka content
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading sacred verse...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 60)
                    } else if let errorMessage = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text("Unable to load shloka")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    } else if let shloka = shlokaContent {
                        VStack(spacing: 28) {
                            // Location Card
                            ShlokaCard(
                                title: "Verse Reference",
                                content: shloka.location,
                                icon: "book.closed.fill",
                                isHighlighted: false,
                                isSmall: true
                            )
                            
                            // Sanskrit Script Card
                            ShlokaCard(
                                title: "Sanskrit Script",
                                content: shloka.script,
                                icon: "textformat.abc",
                                isSanskrit: true
                            )
                            
                            // Transliteration Card
                            ShlokaCard(
                                title: "Transliteration",
                                content: shloka.transliteration,
                                icon: "textformat.alt",
                                isItalic: true
                            )
                            
                            // Translation Card
                            ShlokaCard(
                                title: "Translation",
                                content: shloka.translation,
                                icon: "quote.bubble.fill",
                                isTranslation: true
                            )
                        }
                        .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No shloka available")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("This lesson doesn't have a closing shloka yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical, 24)
            }
            
            // Done button
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                Button(action: {
                    showResults = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "hands.clap.fill")
                            .font(.system(size: 18))
                        Text("Om Shanti, Shanti, Shanti")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            loadShlokaContent()
        }
        .fullScreenCover(isPresented: $showResults) {
            ResultsView(
                lesson: lesson,
                lessonTitle: lessonTitle,
                score: score,
                totalQuestions: totalQuestions,
                timeElapsed: timeElapsed,
                lessonStartTime: lessonStartTime,
                questionsAnswered: questionsAnswered,
                onDismiss: { showResults = false },
                onComplete: onComplete
            )
        }
    }
    
    // MARK: - Data Loading
    
    private func loadShlokaContent() {
        Task {
            do {
                print("📖 Loading shloka for lesson: \(lesson.title) (ID: \(lesson.id))")
                
                // Fetch lesson sections
                let sections = await dataManager.loadLessonSections(for: lesson.id)
                print("   Found \(sections.count) sections")
                
                // Find the CLOSING_PRAYER section
                let shlokaSection = sections.first { $0.kind == .closingPrayer }
                
                await MainActor.run {
                    if let section = shlokaSection {
                        print("   ✅ Found CLOSING_PRAYER section")
                        self.shlokaContent = ShlokaContent(from: section.content)
                        self.errorMessage = nil
                    } else {
                        print("   ⚠️ No CLOSING_PRAYER section found")
                        self.shlokaContent = nil
                        self.errorMessage = nil
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load shloka: \(error.localizedDescription)"
                    self.isLoading = false
                    print("   ❌ Error loading shloka: \(error.localizedDescription)")
                }
            }
        }
    }
    
}

// MARK: - Shloka Card Component

struct ShlokaCard: View {
    let title: String
    let content: String
    let icon: String
    let isHighlighted: Bool
    let isSanskrit: Bool
    let isItalic: Bool
    let isTranslation: Bool
    let isSmall: Bool
    
    init(title: String, content: String, icon: String, isHighlighted: Bool = false, isSanskrit: Bool = false, isItalic: Bool = false, isTranslation: Bool = false, isSmall: Bool = false) {
        self.title = title
        self.content = content
        self.icon = icon
        self.isHighlighted = isHighlighted
        self.isSanskrit = isSanskrit
        self.isItalic = isItalic
        self.isTranslation = isTranslation
        self.isSmall = isSmall
    }
    
    var body: some View {
        VStack(spacing: isSmall ? 8 : 16) {
            // Header with icon and title
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: isSmall ? 14 : 18, weight: .medium))
                    .foregroundColor(isHighlighted ? .white : .orange)
                    .frame(width: isSmall ? 20 : 24, height: isSmall ? 20 : 24)
                
                Text(title)
                    .font(isSmall ? .subheadline : .headline)
                    .fontWeight(isSmall ? .medium : .semibold)
                    .foregroundColor(isHighlighted ? .white : .primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Content
            Text(content)
                .font(isSanskrit ? .system(size: 18, weight: .medium) : (isItalic ? .subheadline : (isSmall ? .caption : .body)))
                .foregroundColor(isHighlighted ? .white : .primary)
                .italic(isItalic)
                .multilineTextAlignment(.center)
                .lineSpacing(isSanskrit ? 8 : 6)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(isSmall ? 12 : 20)
        .background(
            RoundedRectangle(cornerRadius: isSmall ? 12 : 16)
                .fill(
                    isHighlighted ? 
                    LinearGradient(
                        colors: [Color.orange, Color.orange.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: isSmall ? 12 : 16)
                .stroke(
                    isHighlighted ? Color.clear : Color.orange.opacity(isSmall ? 0.1 : 0.2),
                    lineWidth: 1
                )
        )
        .shadow(
            color: isHighlighted ? Color.orange.opacity(0.3) : Color.black.opacity(isSmall ? 0.02 : 0.05),
            radius: isHighlighted ? 8 : (isSmall ? 2 : 4),
            x: 0,
            y: isHighlighted ? 4 : (isSmall ? 1 : 2)
        )
    }
}

#Preview {
    PrayerView(
        lesson: DBLesson(id: UUID(), courseId: UUID(), orderIdx: 2, title: "Sankhya Yoga", imageUrl: nil),
        lessonTitle: "Sankhya Yoga",
        score: 4,
        totalQuestions: 5,
        timeElapsed: 180,
        lessonStartTime: Date(),
        questionsAnswered: [:],
        onDismiss: {},
        onComplete: {}
    )
}
