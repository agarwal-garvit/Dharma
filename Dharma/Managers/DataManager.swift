//
//  DataManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import SwiftUI
import Supabase

@Observable
class DataManager {
    static let shared = DataManager()
    
    // Core data from database
    var courses: [DBCourse] = []
    var lessons: [DBLesson] = []
    var lessonSections: [DBLessonSection] = []
    var quizQuestions: [DBQuizQuestion] = []
    var quizOptions: [DBQuizOption] = []
    
    // Legacy data (for backward compatibility)
    var chapters: [Chapter] = []
    var verses: [Verse] = []
    var exercises: [Exercise] = []
    
    // User data
    var userProgress = UserProgress()
    var userPreferences = UserPreferences()
    var reviewItems: [ReviewItem] = []
    var userStats: DBUserStats?
    
    // Spaced repetition
    private let spacedRepetitionManager = SpacedRepetitionManager()
    private let databaseService = DatabaseService.shared
    
    // Loading states
    var isLoadingCourses = false
    var isLoadingLessons = false
    var errorMessage: String?
    
    private init() {
        loadUserData()
        // Content will be loaded from server
        Task {
            await loadContentFromServer()
        }
    }
    
    // MARK: - Server Data Loading
    
    private func loadContentFromServer() async {
        await loadCourses()
    }
    
    func refreshContent() async {
        await loadCourses()
    }
    
    // MARK: - Database Operations
    
    func loadCourses() async {
        isLoadingCourses = true
        errorMessage = nil
        
        do {
            let fetchedCourses = try await databaseService.fetchAllCourses()
            await MainActor.run {
                self.courses = fetchedCourses
                self.isLoadingCourses = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load courses: \(error.localizedDescription)"
                self.isLoadingCourses = false
            }
        }
    }
    
    func loadLessons(for courseId: UUID) async {
        isLoadingLessons = true
        errorMessage = nil
        
        do {
            let fetchedLessons = try await databaseService.fetchLessons(for: courseId)
            await MainActor.run {
                self.lessons = fetchedLessons
                self.isLoadingLessons = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load lessons: \(error.localizedDescription)"
                self.isLoadingLessons = false
            }
        }
    }
    
    func loadLessonSections(for lessonId: UUID) async -> [DBLessonSection] {
        do {
            let sections = try await databaseService.fetchLessonSections(for: lessonId)
            await MainActor.run {
                self.lessonSections = sections
            }
            return sections
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load lesson sections: \(error.localizedDescription)"
            }
            return []
        }
    }
    
    func loadQuizData(for sectionId: UUID) async -> (questions: [DBQuizQuestion], options: [DBQuizOption]) {
        do {
            let questions = try await databaseService.fetchQuizQuestions(for: sectionId)
            var allOptions: [DBQuizOption] = []
            
            for question in questions {
                let options = try await databaseService.fetchQuizOptions(for: question.id)
                allOptions.append(contentsOf: options)
            }
            
            await MainActor.run {
                self.quizQuestions = questions
                self.quizOptions = allOptions
            }
            
            return (questions, allOptions)
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load quiz data: \(error.localizedDescription)"
            }
            return ([], [])
        }
    }
    
    // MARK: - Helper Methods
    
    func getLessonsForCourse(_ courseId: UUID) -> [DBLesson] {
        return lessons.filter { $0.courseId == courseId }
    }
    
    func getSectionsForLesson(_ lessonId: UUID) -> [DBLessonSection] {
        return lessonSections.filter { $0.lessonId == lessonId }
    }
    
    func getQuestionsForSection(_ sectionId: UUID) -> [DBQuizQuestion] {
        return quizQuestions.filter { $0.sectionId == sectionId }
    }
    
    func getOptionsForQuestion(_ questionId: UUID) -> [DBQuizOption] {
        return quizOptions.filter { $0.questionId == questionId }
    }
    
    // MARK: - Legacy Chapter Conversion
    
    func convertLessonsToChapters() -> [Chapter] {
        return lessons.enumerated().map { index, lesson in
            Chapter(
                id: lesson.id.uuidString,
                index: lesson.orderIdx,
                titleEn: lesson.title,
                titleSa: getSanskritTitle(for: lesson.orderIdx)
            )
        }
    }
    
    private func getSanskritTitle(for orderIdx: Int) -> String {
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
        return titles[orderIdx] ?? "अध्याय \(orderIdx)"
    }
    
    // MARK: - User Data Persistence
    
    private func loadUserData() {
        // Load user progress
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            self.userProgress = progress
        }
        
        // Load user preferences
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.userPreferences = preferences
        }
        
        // Load review items
        if let data = UserDefaults.standard.data(forKey: "reviewItems"),
           let items = try? JSONDecoder().decode([ReviewItem].self, from: data) {
            self.reviewItems = items
        }
    }
    
    func saveUserData() {
        // Save user progress
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: "userProgress")
        }
        
        // Save user preferences
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
        
        // Save review items
        if let data = try? JSONEncoder().encode(reviewItems) {
            UserDefaults.standard.set(data, forKey: "reviewItems")
        }
    }
    
    // MARK: - Verse of the Day
    
    func getVerseOfTheDay() -> Verse? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        
        let index = (dayOfYear - 1) % verses.count
        return verses[index]
    }
    
    // MARK: - Progress Management
    
    func completeLesson(_ lessonId: String) {
        userProgress.completedLessons.insert(lessonId)
        userProgress.totalXP += 10
        
        // Update streak
        updateStreak()
        
        saveUserData()
    }
    
    func completeLesson(_ lessonId: UUID) async {
        // Update local progress
        userProgress.completedLessons.insert(lessonId.uuidString)
        userProgress.totalXP += 50 // Standard lesson completion XP
        
        // Update streak
        updateStreak()
        
        // Save local data
        saveUserData()
        
        // Update database if user is authenticated
        if let userId = DharmaAuthManager.shared.user?.id {
            do {
                // Award XP
                try await databaseService.awardXP(
                    userId: userId,
                    lessonId: lessonId,
                    ruleCode: "LESSON_COMPLETE",
                    xpAmount: 50
                )
                
                // Update lesson progress
                let progress = DBUserLessonProgress(
                    userId: userId,
                    lessonId: lessonId,
                    status: .completed,
                    startedAt: nil,
                    completedAt: ISO8601DateFormatter().string(from: Date()),
                    lastSeenAt: ISO8601DateFormatter().string(from: Date()),
                    lastScorePct: nil,
                    bestScorePct: nil,
                    totalCompletions: 1
                )
                
                try await databaseService.updateUserLessonProgress(progress)
                
            } catch {
                print("Failed to update lesson progress in database: \(error)")
            }
        }
    }
    
    func completeUnit(_ unitId: String) {
        userProgress.completedUnits.insert(unitId)
        userProgress.totalXP += 50
        
        saveUserData()
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastStudyDate = userProgress.lastStudyDate {
            let lastStudyDay = calendar.startOfDay(for: lastStudyDate)
            let daysDifference = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                userProgress.streak += 1
            } else if daysDifference > 1 {
                // Streak broken
                userProgress.streak = 1
            }
            // If daysDifference == 0, it's the same day, keep streak
        } else {
            // First study session
            userProgress.streak = 1
        }
        
        userProgress.lastStudyDate = today
    }
    
    // MARK: - Review Management
    
    func getDueReviewItems() -> [ReviewItem] {
        return spacedRepetitionManager.getDueItems(reviewItems)
    }
    
    func submitReviewAnswer(for item: ReviewItem, wasCorrect: Bool) {
        if let index = reviewItems.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = reviewItems[index]
            spacedRepetitionManager.scheduleNext(item: &updatedItem, wasCorrect: wasCorrect)
            reviewItems[index] = updatedItem
            saveUserData()
        }
    }
    
    // MARK: - Search
    
    func searchVerses(query: String) -> [Verse] {
        let lowercaseQuery = query.lowercased()
        
        return verses.filter { verse in
            verse.translationEn.lowercased().contains(lowercaseQuery) ||
            verse.iastText.lowercased().contains(lowercaseQuery) ||
            verse.devanagariText.contains(query) ||
            verse.keywords.contains { $0.lowercased().contains(lowercaseQuery) } ||
            verse.themes.contains { $0.lowercased().contains(lowercaseQuery) } ||
            verse.reference.contains(query)
        }
    }
    
    // MARK: - Helper Methods
    
    func getVerse(by id: String) -> Verse? {
        return verses.first { $0.id == id }
    }
    
    func getLesson(by id: String) -> Lesson? {
        // Convert DBLesson to legacy Lesson format
        guard let dbLesson = lessons.first(where: { $0.id.uuidString == id }) else {
            return nil
        }
        
        return Lesson(
            id: dbLesson.id.uuidString,
            unitId: dbLesson.courseId.uuidString,
            title: dbLesson.title,
            objective: "Learn about \(dbLesson.title)",
            exerciseIds: []
        )
    }
    
    func getExercise(by id: String) -> Exercise? {
        return exercises.first { $0.id == id }
    }
    
    func getExercises(for lesson: Lesson) -> [Exercise] {
        return lesson.exerciseIds.compactMap { getExercise(by: $0) }
    }
    
    func getVerses(for chapter: Chapter) -> [Verse] {
        return verses.filter { $0.chapterIndex == chapter.index }
    }
}
