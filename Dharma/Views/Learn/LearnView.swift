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
    @State private var currentVisibleCourse: DBCourse?
    @State private var showingCourseSelector = false
    @State private var userStreak = 5 // TODO: Get from database
    @State private var userXP = 1250 // TODO: Get from database
    @State private var courseLessons: [UUID: [DBLesson]] = [:]
    @State private var scrollToCourseId: UUID?
    
    // All courses sorted by course_order
    private var courses: [DBCourse] {
        return dataManager.courses.sorted { course1, course2 in
            let order1 = course1.courseOrder ?? Int.max
            let order2 = course2.courseOrder ?? Int.max
            return order1 < order2
        }
    }
    
    // Current visible course info
    private var currentCourseTitle: String {
        currentVisibleCourse?.title ?? "Select Course"
    }
    
    private var currentCourseLessonCount: String {
        if let courseId = currentVisibleCourse?.id,
           let lessons = courseLessons[courseId] {
            return "\(lessons.count) Lessons"
        }
        return "Lessons"
    }
    
    // Get color for a course (alternates between orange and blue)
    private func courseColor(for course: DBCourse) -> Color {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            return index % 2 == 0 ? Color.orange : Color.blue
        }
        return Color.blue
    }
    
    // Current course color
    private var currentCourseColor: Color {
        if let course = currentVisibleCourse {
            return courseColor(for: course)
        }
        return Color.blue
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // Streak and XP stats bar
                    statsBar
                    
                    // Course selector dropdown
                    courseSelectorCard
                    
                    // Scrollable lessons area
                    if isLoading {
                        loadingView
                    } else {
                        lessonsScrollView
                    }
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
    
    private var statsBar: some View {
        HStack(spacing: 16) {
            // Streak
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))
                
                Text("\(userStreak) day streak")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // XP Points
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18))
                
                Text("\(userXP) XP")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.6))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var courseSelectorCard: some View {
        Button(action: {
            showingCourseSelector = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentCourseTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(currentCourseLessonCount)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(currentCourseColor.opacity(0.85))
                    .shadow(color: currentCourseColor.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingCourseSelector) {
            NavigationStack {
                List(courses) { course in
                    Button(action: {
                        scrollToCourse(course)
                        showingCourseSelector = false
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(course.title)
                                    .font(.headline)
                                if let lessons = courseLessons[course.id] {
                                    Text("\(lessons.count) Lessons")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            if currentVisibleCourse?.id == course.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .navigationTitle("Select Course")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingCourseSelector = false
                        }
                    }
                }
            }
        }
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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 32) {
                    // Display all courses vertically
                    ForEach(Array(courses.enumerated()), id: \.element.id) { courseIndex, course in
                        VStack(spacing: 4) {
                            // Course header with visibility tracking
                            GeometryReader { geometry in
                                courseSectionHeader(course: course)
                                    .id(course.id) // For scrolling to this course
                                    .onChange(of: geometry.frame(in: .global).minY) { _, yPosition in
                                        // Update current course based on scroll direction
                                        // Trigger earlier so it updates before scrolling too far into lessons
                                        
                                        if yPosition <= 250 && yPosition >= -100 {
                                            // Scrolling down: header is approaching or at the top
                                            currentVisibleCourse = course
                                        } else if yPosition > 250 {
                                            // Header moved below the detection zone (scrolling up)
                                            // Set to previous course if exists
                                            if courseIndex > 0 {
                                                currentVisibleCourse = courses[courseIndex - 1]
                                            }
                                        }
                                    }
                            }
                            .frame(height: 40)
                            
                            // Lessons for this course
                            if let lessons = courseLessons[course.id], !lessons.isEmpty {
                                let courseCardColor = courseColor(for: course)
                                VStack(spacing: 0) {
                                    ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                                        HStack {
                                            if index % 2 == 0 {
                                                // Left position
                                                lessonCard(lesson: lesson, courseId: course.id, color: courseCardColor, isLeft: true)
                                                
                                                // Arrow next to left card
                                                if index < lessons.count - 1 {
                                                    arrowNextToCard(for: index, totalLessons: lessons.count)
                                                } else {
                                                    Spacer()
                                                        .frame(width: 136)
                                                }
                                                
                                                Spacer()
                                            } else {
                                                // Right position
                                                Spacer()
                                                
                                                // Arrow next to right card
                                                if index < lessons.count - 1 {
                                                    arrowNextToCard(for: index, totalLessons: lessons.count)
                                                } else {
                                                    Spacer()
                                                        .frame(width: 136)
                                                }
                                                
                                                lessonCard(lesson: lesson, courseId: course.id, color: courseCardColor, isLeft: false)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                // Loading or no lessons
                                Text("Loading lessons...")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .onChange(of: scrollToCourseId) { _, courseId in
                if let courseId = courseId {
                    withAnimation {
                        proxy.scrollTo(courseId, anchor: .top)
                    }
                    scrollToCourseId = nil
                }
            }
        }
    }
    
    private func courseSectionHeader(course: DBCourse) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                // Left line
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 1)
                
                // Course title
                Text(course.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                // Right line
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 1)
            }
            
            // Lesson count
            if let lessons = courseLessons[course.id] {
                Text("\(lessons.count) Lessons")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
    
    private func lessonCard(lesson: DBLesson, courseId: UUID, color: Color, isLeft: Bool) -> some View {
        Button(action: {
            // Find the array index of this lesson within its course
            if let lessons = courseLessons[courseId],
               let arrayIndex = lessons.firstIndex(where: { $0.id == lesson.id }) {
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
                    .stroke(color.opacity(0.9), lineWidth: 4)
            )
            .shadow(
                color: isLessonUnlocked(lesson) ? color.opacity(0.2) : Color.black.opacity(0.1),
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
            // Load all courses
            await dataManager.loadCourses()
            print("📚 Courses loaded: \(dataManager.courses.count)")
            
            // Load lessons for ALL courses
            for course in dataManager.courses {
                print("📖 Loading lessons for course: \(course.title)")
                await dataManager.loadLessons(for: course.id)
                
                await MainActor.run {
                    // Store lessons for this course
                    courseLessons[course.id] = dataManager.lessons
                }
            }
            
            // Set first course as visible
            if let firstCourse = dataManager.courses.first {
                await MainActor.run {
                    currentVisibleCourse = firstCourse
                    isLoading = false
                    print("✅ Content loading completed. All courses loaded.")
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    print("❌ No courses found")
                }
            }
        }
    }
    
    private func scrollToCourse(_ course: DBCourse) {
        scrollToCourseId = course.id
        currentVisibleCourse = course
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
    
    private func isLessonUnlocked(_ lesson: DBLesson) -> Bool {
        // For now, all lessons are unlocked
        // You can implement your own logic here based on user progress
        return true
    }
    
    private func arrowNextToCard(for index: Int, totalLessons: Int) -> some View {
        let isLeftPosition = index % 2 == 0
        let nextIsLeftPosition = (index + 1) % 2 == 0
        
        if isLeftPosition && !nextIsLeftPosition {
            // Arrow from left card to right card (top-left to bottom-right)
            return AnyView(
                Image("downRight")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 108)
                    .padding(.leading, 4)
                    .padding(.top, 40)
            )
        } else {
            // Arrow from right card to left card (top-right to bottom-left)
            return AnyView(
                Image("downLeft")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 108)
                    .padding(.trailing, 4)
                    .padding(.top, 40)
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
