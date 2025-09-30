//
//  DataManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import SwiftUI

@Observable
class DataManager {
    static let shared = DataManager()
    
    // Core data
    var chapters: [Chapter] = []
    var verses: [Verse] = []
    var lessons: [Lesson] = []
    var exercises: [Exercise] = []
    
    // User data
    var userProgress = UserProgress()
    var userPreferences = UserPreferences()
    var reviewItems: [ReviewItem] = []
    
    // Spaced repetition
    private let spacedRepetitionManager = SpacedRepetitionManager()
    
    private init() {
        loadUserData()
        // Content will be loaded from server
        loadContentFromServer()
    }
    
    // MARK: - Server Data Loading
    
    private func loadContentFromServer() {
        // TODO: Implement server API calls
        // For now, initialize with empty data
        self.chapters = []
        self.verses = []
        self.lessons = []
        self.exercises = []
    }
    
    func refreshContent() async {
        // TODO: Implement server API calls to fetch latest content
        // This will be called when the app starts or when user pulls to refresh
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
        return lessons.first { $0.id == id }
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
