//
//  LearnView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct LearnView: View {
    @State private var dataManager = DataManager.shared
    @State private var isLoading = true
    @State private var showingLessonPlayer = false
    @State private var selectedLesson: DBLesson?
    @State private var showingProfile = false
    @State private var currentVisibleCourse: DBCourse?
    @State private var showingCourseSelector = false
    @State private var userStreak = 0
    @State private var userMetrics: DBUserMetrics?
    @State private var loginSessions: [DBUserLoginSession] = []
    @State private var courseLessons: [UUID: [DBLesson]] = [:]
    @State private var scrollToCourseId: UUID?
    @State private var navigateToProgress = false
    @State private var lessonProgress: [UUID: DBLessonProgress] = [:]
    @State private var showLockedAlert = false
    @State private var lockedAlertMessage = ""
    @State private var showLivesModal = false
    @State private var livesManager = LivesManager.shared
    
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
                
                if isLoading {
                    // Full screen loading view
                    loadingView
                        .transition(.opacity)
                } else {
                    // Main content
                    VStack(spacing: 8) {
                        // Streak and XP stats bar
                        statsBar
                        
                        // Course selector dropdown
                        courseSelectorCard
                        
                        // Scrollable lessons area
                        lessonsScrollView
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isLoading)
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange.opacity(0.7))
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isLoading {
                        LivesDisplayView()
                    }
                }
            }
        }
        .onAppear {
            loadContent()
            loadUserMetrics()
            
            // Check and regenerate lives
            Task {
                await livesManager.checkAndRegenerateLives()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .lessonCompleted)) { _ in
            // Reload progress when a lesson is completed
            loadUserLessonProgress()
        }
        .onReceive(NotificationCenter.default.publisher(for: .streakUpdated)) { _ in
            // Reload metrics when streak is updated (after login)
            print("📊 LearnView received streakUpdated notification - reloading metrics")
            loadUserMetrics()
        }
        .fullScreenCover(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson, onLessonSelected: { legacyLesson in
                showingLessonPlayer = true
            })
            .onAppear {
                print("Presenting LessonDetailView for Lesson \(lesson.title)")
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
        .onChange(of: navigateToProgress) { _, shouldNavigate in
            if shouldNavigate {
                // Post notification to switch to progress tab
                NotificationCenter.default.post(name: .switchToProgressTab, object: nil)
                navigateToProgress = false
            }
        }
        .alert("Lesson Locked", isPresented: $showLockedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(lockedAlertMessage)
        }
        .sheet(isPresented: $showLivesModal) {
            LivesModalView()
        }
    }
    
    private var statsBar: some View {
        Button(action: {
            navigateToProgress = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))
                
                Text("\(userStreak) day streak")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
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
                                                    // Show invisible arrow for last lesson to maintain consistent spacing
                                                    arrowNextToCard(for: index, totalLessons: lessons.count)
                                                        .opacity(0)
                                                }
                                                
                                                Spacer()
                                            } else {
                                                // Right position
                                                Spacer()
                                                
                                                // Arrow next to right card
                                                if index < lessons.count - 1 {
                                                    arrowNextToCard(for: index, totalLessons: lessons.count)
                                                } else {
                                                    // Show invisible arrow for last lesson to maintain consistent spacing
                                                    arrowNextToCard(for: index, totalLessons: lessons.count)
                                                        .opacity(0)
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
            // Check lives first
            if livesManager.currentLives == 0 {
                print("❌ No lives remaining - showing lives modal")
                showLivesModal = true
                return
            }
            
            if isLessonUnlocked(lesson) {
                // Lesson is unlocked - open it
                print("Lesson \(lesson.title) (ID: \(lesson.id)) from course \(courseId) tapped - isUnlocked: true")
                selectedLesson = lesson
                print("Selected lesson set: \(lesson.title)")
            } else {
                // Lesson is locked - show alert
                print("Lesson \(lesson.title) is locked")
                lockedAlertMessage = "Complete previous lessons with 80% accuracy or higher to unlock this lesson."
                showLockedAlert = true
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
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
            }
            .frame(width: 200, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(isLessonUnlocked(lesson) ? 0.9 : 0.4), lineWidth: 4)
            )
            .overlay(
                // Dimming overlay for locked lessons
                Group {
                    if !isLessonUnlocked(lesson) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.5))
                    }
                }
            )
            .shadow(
                color: isLessonUnlocked(lesson) ? color.opacity(0.2) : Color.black.opacity(0.1),
                radius: isLessonUnlocked(lesson) ? 8 : 4,
                x: 0,
                y: isLessonUnlocked(lesson) ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isLessonUnlocked(lesson) ? 1.0 : 0.7)
        .scaleEffect(isLessonUnlocked(lesson) ? 1.0 : 0.96)
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
                print("📖 Loading lessons for course: \(course.title) (ID: \(course.id))")
                let lessons = await dataManager.loadLessons(for: course.id)
                
                await MainActor.run {
                    // Store lessons for this specific course
                    courseLessons[course.id] = lessons
                    print("   ✅ Stored \(lessons.count) lessons for course: \(course.title)")
                }
            }
            
            // Preload all lesson images in background
            await preloadLessonImages()
            
            // Set first course as visible
            if let firstCourse = dataManager.courses.first {
                await MainActor.run {
                    currentVisibleCourse = firstCourse
                    print("✅ Content loading completed. All courses and images loaded.")
                    
                    // Load user progress for lessons after courses and lessons are loaded
                    loadUserLessonProgress()
                }
                
                // Small delay to ensure UI is fully rendered before removing loading screen
                try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
                
                await MainActor.run {
                    isLoading = false
                    print("✅ Loading screen dismissed")
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    print("❌ No courses found")
                }
            }
        }
    }
    
    private func preloadLessonImages() async {
        print("🖼️ Starting image preloading...")
        let storageManager = StorageManager.shared
        
        // Collect all lesson images that need preloading
        var imagesToPreload: [URL] = []
        
        for (_, lessons) in courseLessons {
            for lesson in lessons {
                if let imageUrlString = lesson.imageUrl,
                   let imageUrl = URL(string: imageUrlString) {
                    // Only preload if not already cached
                    if storageManager.getCachedImage(for: imageUrl) == nil {
                        imagesToPreload.append(imageUrl)
                    }
                }
            }
        }
        
        print("🖼️ Found \(imagesToPreload.count) images to preload")
        
        // Preload images in batches to avoid overwhelming the network
        let batchSize = 5
        for i in stride(from: 0, to: imagesToPreload.count, by: batchSize) {
            let batch = Array(imagesToPreload[i..<min(i + batchSize, imagesToPreload.count)])
            
            await withTaskGroup(of: Void.self) { group in
                for imageUrl in batch {
                    group.addTask {
                        await self.preloadSingleImage(url: imageUrl)
                    }
                }
            }
            
            // Small delay between batches to be network-friendly
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        print("✅ Image preloading completed")
    }
    
    private func preloadSingleImage(url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    StorageManager.shared.cacheImage(image, for: url)
                }
            }
        } catch {
            print("❌ Failed to preload image from \(url): \(error.localizedDescription)")
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
        // Find all lessons in the same course
        guard let lessonsInCourse = courseLessons[lesson.courseId] else {
            return false
        }
        
        // Sort lessons by order_idx
        let sortedLessons = lessonsInCourse.sorted { $0.orderIdx < $1.orderIdx }
        
        // First lesson (minimum order_idx) is always unlocked
        if sortedLessons.first?.id == lesson.id {
            return true
        }
        
        // Find the previous lesson in the sorted order
        guard let currentIndex = sortedLessons.firstIndex(where: { $0.id == lesson.id }),
              currentIndex > 0 else {
            return false
        }
        
        let previousLesson = sortedLessons[currentIndex - 1]
        
        // Check if previous lesson has been completed with 80% or higher
        if let progress = lessonProgress[previousLesson.id] {
            return progress.bestScorePercentage >= 80.0
        }
        
        // If no progress data for previous lesson, it's locked
        return false
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
    
    private func isDateActive(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        dayFormatter.timeZone = TimeZone.current
        let dateString = dayFormatter.string(from: date)
        
        let isoFormatter = ISO8601DateFormatter()
        
        return loginSessions.contains { session in
            if let sessionDate = isoFormatter.date(from: session.loginTimestamp) {
                // Use the original timezone from when the user logged in
                let originalTimezone = session.userTimezone ?? TimeZone.current.identifier
                let sessionDayFormatter = DateFormatter()
                sessionDayFormatter.dateFormat = "yyyy-MM-dd"
                sessionDayFormatter.timeZone = TimeZone(identifier: originalTimezone)
                let sessionDateString = sessionDayFormatter.string(from: sessionDate)
                return sessionDateString == dateString
            }
            return false
        }
    }
    
    /// Calculates the current streak using the same logic as the calendar section
    /// Goes back day by day from today, checking if each day is active (has login sessions)
    /// This ensures consistency between the streak display and calendar active days
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        dayFormatter.timeZone = TimeZone.current
        
        // Start from today and go backwards day by day
        var currentDate = calendar.startOfDay(for: Date())
        var streak = 0
        
        // Check if today is active
        if isDateActive(currentDate) {
            streak = 1
            
            // Keep going backwards day by day
            while true {
                // Go back one day
                guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                
                // Check if the previous day is active
                if isDateActive(previousDate) {
                    streak += 1
                    currentDate = previousDate
                } else {
                    // Streak broken
                    break
                }
            }
        }
        
        return streak
    }
    
    private func loadUserMetrics() {
        Task {
            let authManager = DharmaAuthManager.shared
            async let metrics = authManager.getUserMetrics()
            // Fetch more sessions to cover 90+ days even with multiple logins per day
            async let sessions = authManager.getLoginSessions(limit: 500)
            
            let (fetchedMetrics, fetchedSessions) = await (metrics, sessions)
            
            await MainActor.run {
                self.loginSessions = fetchedSessions
                
                // Calculate streak locally using login sessions (same logic as calendar)
                let calculatedStreak = self.calculateCurrentStreak()
                
                // Update the metrics with our locally calculated streak
                if var updatedMetrics = fetchedMetrics {
                    // Create a new DBUserMetrics with our calculated streak
                    self.userMetrics = DBUserMetrics(
                        totalXp: updatedMetrics.totalXp,
                        currentStreak: calculatedStreak,
                        longestStreak: updatedMetrics.longestStreak,
                        lessonsCompleted: updatedMetrics.lessonsCompleted,
                        totalStudyTimeMinutes: updatedMetrics.totalStudyTimeMinutes,
                        quizAverageScore: updatedMetrics.quizAverageScore
                    )
                } else {
                    self.userMetrics = fetchedMetrics
                }
                
                self.userStreak = calculatedStreak
            }
        }
    }
    
    private func loadUserLessonProgress() {
        guard let userId = dataManager.currentUserId else {
            print("⚠️ No user ID available to load lesson progress")
            return
        }
        
        Task {
            do {
                // Load all lesson progress at once from lesson_completions
                let progressMap = try await DatabaseService.shared.fetchAllLessonProgress(userId: userId)
                
                await MainActor.run {
                    self.lessonProgress = progressMap
                    print("✅ Loaded progress for \(progressMap.count) lessons from lesson_completions")
                }
            } catch {
                print("❌ Failed to load lesson progress: \(error)")
                await MainActor.run {
                    self.lessonProgress = [:]
                }
            }
        }
    }
}


struct LessonDetailView: View {
    let lesson: DBLesson
    let onLessonSelected: (Lesson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var showSummary = false
    @State private var dataManager = DataManager.shared
    @State private var lessonSections: [DBLessonSection] = []
    @State private var lessonStartTime = Date()
    
    private var lessonTitle: String {
        return lesson.title
    }
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if showSummary {
                LessonSummaryView(
                    lesson: lesson,
                    lessonTitle: lessonTitle,
                    lessonSections: lessonSections,
                    lessonStartTime: lessonStartTime,
                    onDismiss: { dismiss() }
                )
            }
        }
        .onAppear {
            lessonStartTime = Date() // Set the actual lesson start time
            print("📚 Lesson \(lesson.title) (ID: \(lesson.id)) started at: \(lessonStartTime)")
            print("Initial state - isLoading: \(isLoading), showSummary: \(showSummary)")
            
            // Load lesson sections from database
            Task {
                let sections = await dataManager.loadLessonSections(for: lesson.id)
                await MainActor.run {
                    self.lessonSections = sections
                    self.isLoading = false
                    self.showSummary = true
                    print("Loading completed for Lesson \(lesson.title) - Loaded \(sections.count) sections")
                    print("Final state - isLoading: \(isLoading), showSummary: \(showSummary)")
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
                
                Text("Lesson \(lesson.orderIdx)")
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
