//
//  LearnView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct LessonIndex: Identifiable {
    let id: Int
    let value: Int
    
    init(_ value: Int) {
        self.id = value
        self.value = value
    }
}

struct LearnView: View {
    @State private var dataManager = DataManager.shared
    @State private var isLoading = true
    @State private var selectedLessonIndex: Int?
    @State private var showingLessonDetail = false
    @State private var showingLessonPlayer = false
    @State private var selectedLesson: DBLesson?
    @State private var showingProfile = false
    @State private var lessonToShow: LessonIndex?
    @State private var currentCourseTitle = "Bhagavad Gita"
    @State private var currentCourseLessons = "Lessons"
    @State private var selectedCourse: DBCourse?
    
    // Get lessons from database (already sorted by order_idx)
    private var lessons: [DBLesson] {
        return dataManager.lessons
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
        .fullScreenCover(item: $lessonToShow) { lessonIndexWrapper in
            LessonDetailView(lessonIndex: lessonIndexWrapper.value, onLessonSelected: { lesson in
                // Find the corresponding DBLesson by array index
                if lessonIndexWrapper.value < dataManager.lessons.count {
                    let dbLesson = dataManager.lessons[lessonIndexWrapper.value]
                    selectedLesson = dbLesson
                    lessonToShow = nil
                    showingLessonPlayer = true
                }
            })
            .onAppear {
                print("Presenting LessonDetailView for Lesson \(lessonIndexWrapper.value)")
            }
        }
        .fullScreenCover(isPresented: $showingLessonPlayer) {
            if let lesson = selectedLesson {
                // Convert DBLesson to legacy Lesson for compatibility
                let legacyLesson = Lesson(
                    id: lesson.id.uuidString,
                    unitId: lesson.courseId.uuidString,
                    title: lesson.title,
                    objective: "Learn about \(lesson.title)",
                    exerciseIds: []
                )
                LessonPlayerView(lesson: legacyLesson) {
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
            
            Text(currentCourseLessons)
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
                    ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                        HStack {
                            if index % 2 == 0 {
                                // Left position
                                lessonCard(lesson: lesson, isLeft: true)
                                    .onAppear {
                                        updateCourseTitle(for: index)
                                    }
                                
                                // Arrow next to left card
                                if index < lessons.count - 1 {
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
                                if index < lessons.count - 1 {
                                    arrowNextToCard(for: index)
                                } else {
                                    // Empty space for last card
                                    Spacer()
                                        .frame(width: 136) // Same width as arrow + padding
                                }
                                
                                lessonCard(lesson: lesson, isLeft: false)
                                    .onAppear {
                                        updateCourseTitle(for: index)
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
    
    private func lessonCard(lesson: DBLesson, isLeft: Bool) -> some View {
        Button(action: {
            // Find the array index of this lesson
            if let arrayIndex = lessons.firstIndex(where: { $0.id == lesson.id }) {
                print("Lesson \(lesson.title) tapped (array index: \(arrayIndex)) - isUnlocked: \(isLessonUnlocked(lesson))")
                lessonToShow = LessonIndex(arrayIndex)
                selectedLessonIndex = arrayIndex
                print("State set - lessonToShow: \(lessonToShow?.value ?? -1), selectedLessonIndex: \(selectedLessonIndex ?? -1)")
                print("Sheet presentation triggered - lessonToShow: \(lessonToShow?.value ?? -1)")
            }
        }) {
            ZStack {
                // Background - Image or Gradient
                if let imageUrlString = lesson.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    CachedAsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 120)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    }
                } else {
                    // Fallback gradient if no image
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "book.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
                
                // Translucent gradient overlay behind text (left to right fade)
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.2),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                // Overlay - Text content
                VStack(alignment: .leading, spacing: 8) {
                    // Lesson title
                    Text(lesson.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Arrow indicator at bottom
                    HStack {
                        Spacer()
                        if isLessonUnlocked(lesson) {
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(16)
            }
            .frame(width: 200, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.9), lineWidth: 4)
            )
            .shadow(
                color: isLessonUnlocked(lesson) ? Color.blue.opacity(0.2) : Color.black.opacity(0.1),
                radius: isLessonUnlocked(lesson) ? 8 : 4,
                x: 0,
                y: isLessonUnlocked(lesson) ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isLessonUnlocked(lesson))
        .scaleEffect(isLessonUnlocked(lesson) ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isLessonUnlocked(lesson))
    }
    
    
    private func loadContent() {
        isLoading = true
        print("🔄 Starting to load content...")
        
        Task {
            // Load courses first
            await dataManager.loadCourses()
            print("📚 Courses loaded: \(dataManager.courses.count)")
            
            // If we have courses, load lessons for the first course (Bhagavad Gita)
            if let firstCourse = dataManager.courses.first {
                selectedCourse = firstCourse
                currentCourseTitle = firstCourse.title
                print("📖 Loading lessons for course: \(firstCourse.title)")
                
                await dataManager.loadLessons(for: firstCourse.id)
                
                await MainActor.run {
                    currentCourseLessons = "\(dataManager.lessons.count) Lessons"
                    isLoading = false
                    print("✅ Content loading completed. Lessons: \(dataManager.lessons.count)")
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    print("❌ No courses found")
                }
            }
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
    
    private func updateCourseTitle(for lessonIndex: Int) {
        // Update course title based on selected course
        if let course = selectedCourse {
            currentCourseTitle = course.title
            currentCourseLessons = "\(dataManager.lessons.count) Lessons"
        } else {
            currentCourseTitle = "Bhagavad Gita"
            currentCourseLessons = "\(lessons.count) Lessons"
        }
    }
    
    private func isLessonUnlocked(_ lesson: DBLesson) -> Bool {
        // For now, all lessons are unlocked
        // You can implement your own logic here based on user progress
        return true
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


struct LessonDetailView: View {
    let lessonIndex: Int
    let onLessonSelected: (Lesson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var showSummary = false
    @State private var dataManager = DataManager.shared
    @State private var lessonSections: [DBLessonSection] = []
    @State private var lessonStartTime = Date()
    
    private var lessonTitle: String {
        // Get title from database lesson by array index
        if lessonIndex < dataManager.lessons.count {
            return dataManager.lessons[lessonIndex].title
        }
        
        return "Lesson \(lessonIndex + 1)"
    }
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if showSummary {
                LessonSummaryView(
                    lessonIndex: lessonIndex,
                    lessonTitle: lessonTitle,
                    lessonSections: lessonSections,
                    lessonStartTime: lessonStartTime,
                    onDismiss: { dismiss() }
                )
            }
        }
        .onAppear {
            lessonStartTime = Date() // Set the actual lesson start time
            print("📚 Lesson \(lessonIndex) started at: \(lessonStartTime)")
            print("Initial state - isLoading: \(isLoading), showSummary: \(showSummary)")
            
            // Load lesson sections from database
            Task {
                if lessonIndex < dataManager.lessons.count {
                    let lesson = dataManager.lessons[lessonIndex]
                    let sections = await dataManager.loadLessonSections(for: lesson.id)
                    await MainActor.run {
                        self.lessonSections = sections
                        self.isLoading = false
                        self.showSummary = true
                        print("Loading completed for Lesson \(lessonIndex)")
                        print("Final state - isLoading: \(isLoading), showSummary: \(showSummary)")
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.showSummary = true
                    }
                }
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
                Text(lessonTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Lesson \(lessonIndex + 1)")
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
