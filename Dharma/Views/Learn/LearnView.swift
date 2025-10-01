//
//  LearnView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

extension Int: Identifiable {
    public var id: Int { self }
}

struct LearnView: View {
    @State private var dataManager = DataManager.shared
    @State private var isLoading = true
    @State private var selectedChapterIndex: Int?
    @State private var showingChapterDetail = false
    @State private var showingLessonPlayer = false
    @State private var selectedLesson: Lesson?
    @State private var showingProfile = false
    @State private var chapterToShow: Int?
    @State private var currentCourseTitle = "Bhagavad Gita"
    @State private var currentCourseChapters = "18 Chapters"
    
    // Create 18 chapters for the Bhagavad Gita
    private var chapters: [Chapter] {
        (1...18).map { index in
            Chapter(
                id: "ch\(index)",
                index: index,
                titleEn: Self.getChapterTitle(index),
                titleSa: Self.getChapterTitleSanskrit(index)
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed course title card that changes based on visible content
                courseTitleCard
                
                // Scrollable lessons area
                if isLoading {
                    loadingView
                } else {
                    lessonsScrollView
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue.opacity(0.7))
                        }
                    }
                }
            }
        }
        .onAppear {
            loadContent()
        }
        .fullScreenCover(item: $chapterToShow) { chapterIndex in
            ChapterDetailView(chapterIndex: chapterIndex, onLessonSelected: { lesson in
                selectedLesson = lesson
                chapterToShow = nil
                showingLessonPlayer = true
            })
            .onAppear {
                print("Presenting ChapterDetailView for Chapter \(chapterIndex)")
            }
        }
        .fullScreenCover(isPresented: $showingLessonPlayer) {
            if let lesson = selectedLesson {
                LessonPlayerView(lesson: lesson) {
                    showingLessonPlayer = false
                    selectedLesson = nil
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
    
    private var courseTitleCard: some View {
        VStack(spacing: 4) {
            Text(currentCourseTitle)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(currentCourseChapters)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: Color.blue.opacity(0.2),
                    radius: 6,
                    x: 0,
                    y: 3
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading lessons...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var lessonsScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Staggered layout for lessons
                VStack(spacing: 0) {
                    ForEach(Array(chapters.enumerated()), id: \.element.id) { index, chapter in
                        HStack {
                            if index % 2 == 0 {
                                // Left position
                                lessonCard(chapter: chapter, isLeft: true)
                                    .onAppear {
                                        updateCourseTitle(for: chapter.index)
                                    }
                                
                                // Arrow next to left card
                                if index < chapters.count - 1 {
                                    arrowNextToCard(for: index)
                                } else {
                                    // Empty space for last card
                                    Spacer()
                                        .frame(width: 136) // Same width as arrow + padding
                                }
                                
                                Spacer()
                            } else {
                                // Right position
                                Spacer()
                                
                                // Arrow next to right card
                                if index < chapters.count - 1 {
                                    arrowNextToCard(for: index)
                                } else {
                                    // Empty space for last card
                                    Spacer()
                                        .frame(width: 136) // Same width as arrow + padding
                                }
                                
                                lessonCard(chapter: chapter, isLeft: false)
                                    .onAppear {
                                        updateCourseTitle(for: chapter.index)
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Future: Additional courses will be added here
                // For example, when you add Mahabharata:
                // [Mahabharata lessons...]
            }
            .padding(.bottom, 20)
        }
    }
    
    private func lessonCard(chapter: Chapter, isLeft: Bool) -> some View {
        Button(action: {
            print("Chapter \(chapter.index) tapped - isUnlocked: \(isChapterUnlocked(chapter))")
            chapterToShow = chapter.index
            selectedChapterIndex = chapter.index
            print("State set - chapterToShow: \(chapterToShow), selectedChapterIndex: \(selectedChapterIndex)")
            print("Sheet presentation triggered - chapterToShow: \(chapterToShow)")
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Chapter title only
                Text(chapter.titleEn)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isChapterUnlocked(chapter) ? .primary : .secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Arrow indicator at bottom
                HStack {
                    Spacer()
                    if isChapterUnlocked(chapter) {
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.blue.opacity(0.7))
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .frame(width: 200, height: 120) // Fixed width and height for consistent card size
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isChapterUnlocked(chapter) ? 
                                [Color(.systemBackground), Color(.systemBackground).opacity(0.95)] : 
                                [Color(.systemGray6), Color(.systemGray6).opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isChapterUnlocked(chapter) ? Color.blue.opacity(0.2) : Color.black.opacity(0.1),
                        radius: isChapterUnlocked(chapter) ? 8 : 4,
                        x: 0,
                        y: isChapterUnlocked(chapter) ? 4 : 2
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isChapterUnlocked(chapter) ? Color.blue.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isChapterUnlocked(chapter))
        .scaleEffect(isChapterUnlocked(chapter) ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isChapterUnlocked(chapter))
    }
    
    
    private func loadContent() {
        isLoading = true
        
        // Simulate loading from server
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
        }
    }
    
    private func isChapterUnlocked(_ chapter: Chapter) -> Bool {
        // First chapter is always unlocked
        if chapter.index == 1 {
            return true
        }
        
        // For now, unlock first 3 chapters for demo
        return chapter.index <= 3
    }
    
    private func getChapterProgress(_ chapter: Chapter) -> Double {
        // For now, return 0 progress for all chapters
        return 0.0
    }
    
    private func updateCourseTitle(for chapterIndex: Int) {
        // For now, all chapters belong to Bhagavad Gita
        // In the future, you can add logic to determine which course a chapter belongs to
        if chapterIndex >= 1 && chapterIndex <= 18 {
            currentCourseTitle = "Bhagavad Gita"
            currentCourseChapters = "18 Chapters"
        }
        // Future: Add logic for other courses
        // else if chapterIndex >= 19 && chapterIndex <= 36 {
        //     currentCourseTitle = "Mahabharata"
        //     currentCourseChapters = "18 Chapters"
        // }
    }
    
    private func arrowNextToCard(for index: Int) -> some View {
        let isLeftPosition = index % 2 == 0
        let nextIsLeftPosition = (index + 1) % 2 == 0
        
        if isLeftPosition && !nextIsLeftPosition {
            // Arrow from left card to right card (top-left to bottom-right)
            return AnyView(
                Image("downRight")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 108) // Reduced width, same height
                    .padding(.leading, 4) // Moved left
                    .padding(.top, 40) // Moved lower
            )
        } else {
            // Arrow from right card to left card (top-right to bottom-left)
            return AnyView(
                Image("downLeft")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 108) // Reduced width, same height
                    .padding(.trailing, 4) // Moved right
                    .padding(.top, 40) // Moved lower
            )
        }
    }
    
    private static func getChapterTitle(_ index: Int) -> String {
        let titles = [
            1: "Arjuna's Despair",
            2: "Sankhya Yoga",
            3: "Karma Yoga",
            4: "Jnana Yoga",
            5: "Karma Sannyasa Yoga",
            6: "Dhyana Yoga",
            7: "Jnana Vijnana Yoga",
            8: "Akshara Brahma Yoga",
            9: "Raja Vidya Yoga",
            10: "Vibhuti Yoga",
            11: "Vishvarupa Darshana Yoga",
            12: "Bhakti Yoga",
            13: "Kshetra Kshetrajna Yoga",
            14: "Gunatraya Vibhaga Yoga",
            15: "Purushottama Yoga",
            16: "Daivasura Sampad Vibhaga Yoga",
            17: "Shraddhatraya Vibhaga Yoga",
            18: "Moksha Sannyasa Yoga"
        ]
        return titles[index] ?? "Chapter \(index)"
    }
    
    private static func getChapterTitleSanskrit(_ index: Int) -> String {
        let titles = [
            1: "अर्जुनविषादयोग",
            2: "सांख्ययोग",
            3: "कर्मयोग",
            4: "ज्ञानयोग",
            5: "कर्मसंन्यासयोग",
            6: "ध्यानयोग",
            7: "ज्ञानविज्ञानयोग",
            8: "अक्षरब्रह्मयोग",
            9: "राजविद्याराजगुह्ययोग",
            10: "विभूतियोग",
            11: "विश्वरूपदर्शनयोग",
            12: "भक्तियोग",
            13: "क्षेत्रक्षेत्रज्ञयोग",
            14: "गुणत्रयविभागयोग",
            15: "पुरुषोत्तमयोग",
            16: "दैवासुरसम्पद्विभागयोग",
            17: "श्रद्धात्रयविभागयोग",
            18: "मोक्षसंन्यासयोग"
        ]
        return titles[index] ?? "अध्याय \(index)"
    }
}


struct ChapterDetailView: View {
    let chapterIndex: Int
    let onLessonSelected: (Lesson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var showSummary = false
    
    private var chapterTitle: String {
        let titles = [
            1: "Arjuna's Despair",
            2: "Sankhya Yoga",
            3: "Karma Yoga",
            4: "Jnana Yoga",
            5: "Karma Sannyasa Yoga",
            6: "Dhyana Yoga",
            7: "Jnana Vijnana Yoga",
            8: "Akshara Brahma Yoga",
            9: "Raja Vidya Yoga",
            10: "Vibhuti Yoga",
            11: "Vishvarupa Darshana Yoga",
            12: "Bhakti Yoga",
            13: "Kshetra Kshetrajna Yoga",
            14: "Gunatraya Vibhaga Yoga",
            15: "Purushottama Yoga",
            16: "Daivasura Sampad Vibhaga Yoga",
            17: "Shraddhatraya Vibhaga Yoga",
            18: "Moksha Sannyasa Yoga"
        ]
        return titles[chapterIndex] ?? "Chapter \(chapterIndex)"
    }
    
    var body: some View {
        NavigationView {
            if isLoading {
                loadingView
            } else if showSummary {
                ChapterSummaryView(
                    chapterIndex: chapterIndex,
                    chapterTitle: chapterTitle,
                    onDismiss: { dismiss() }
                )
            }
        }
        .onAppear {
            print("ChapterDetailView appeared for Chapter \(chapterIndex)")
            print("Initial state - isLoading: \(isLoading), showSummary: \(showSummary)")
            
            // Simulate loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("Loading completed for Chapter \(chapterIndex)")
                isLoading = false
                showSummary = true
                print("Final state - isLoading: \(isLoading), showSummary: \(showSummary)")
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 32) {
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
                    .frame(width: 120, height: 120)
                
                Text("🐄")
                    .font(.system(size: 60))
            }
            
            VStack(spacing: 16) {
                Text(chapterTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Chapter \(chapterIndex)")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LearnView()
}
