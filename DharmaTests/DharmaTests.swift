//
//  DharmaTests.swift
//  DharmaTests
//
//  Created by Garvit Agarwal on 9/28/25.
//

import XCTest
@testable import Dharma

final class DharmaTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Data Model Tests
    
    func testVerseModel() throws {
        let verse = Verse(
            id: "v2_47",
            chapterIndex: 2,
            verseIndex: 47,
            devanagariText: "कर्मण्येवाधिकारस्ते",
            iastText: "karmaṇy-evādhikāras te",
            translationEn: "You have a right to action alone",
            keywords: ["karma", "detachment"],
            audioURL: "bundle://audio/v2_47.mp3",
            commentaryShort: "Focus on action, not results",
            themes: ["duty", "equanimity"]
        )
        
        XCTAssertEqual(verse.id, "v2_47")
        XCTAssertEqual(verse.chapterIndex, 2)
        XCTAssertEqual(verse.verseIndex, 47)
        XCTAssertEqual(verse.reference, "2.47")
        XCTAssertEqual(verse.keywords.count, 2)
        XCTAssertEqual(verse.themes.count, 2)
    }
    
    func testExerciseModel() throws {
        let exercise = Exercise(
            id: "ex1",
            type: .multipleChoice,
            prompt: "What is the main teaching?",
            options: ["Option 1", "Option 2", "Option 3"],
            correctAnswer: "Option 1",
            hints: ["Hint 1", "Hint 2"],
            assetRefs: ["asset1"],
            verseRefs: ["v2_47"]
        )
        
        XCTAssertEqual(exercise.id, "ex1")
        XCTAssertEqual(exercise.type, .multipleChoice)
        XCTAssertEqual(exercise.options?.count, 3)
        XCTAssertEqual(exercise.hints?.count, 2)
    }
    
    // MARK: - Spaced Repetition Tests
    
    func testSpacedRepetitionScheduling() throws {
        let manager = SpacedRepetitionManager()
        var item = ReviewItem(id: "test", kind: .verse, payloadRef: "v2_47")
        
        // Test correct answer progression
        let initialBox = item.box
        manager.scheduleNext(item: &item, wasCorrect: true)
        XCTAssertEqual(item.box, initialBox + 1)
        
        // Test incorrect answer reset
        item.box = 3
        manager.scheduleNext(item: &item, wasCorrect: false)
        XCTAssertEqual(item.box, 1)
    }
    
    func testDueItemsFiltering() throws {
        let manager = SpacedRepetitionManager()
        let now = Date()
        
        let pastItem = ReviewItem(id: "past", kind: .verse, payloadRef: "v1")
        pastItem.nextDueAt = Calendar.current.date(byAdding: .hour, value: -1, to: now) ?? now
        
        let futureItem = ReviewItem(id: "future", kind: .verse, payloadRef: "v2")
        futureItem.nextDueAt = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
        
        let items = [pastItem, futureItem]
        let dueItems = manager.getDueItems(items)
        
        XCTAssertEqual(dueItems.count, 1)
        XCTAssertEqual(dueItems.first?.id, "past")
    }
    
    // MARK: - User Progress Tests
    
    func testUserProgressInitialization() throws {
        let progress = UserProgress()
        
        XCTAssertEqual(progress.streak, 0)
        XCTAssertEqual(progress.totalXP, 0)
        XCTAssertEqual(progress.hearts, 5)
        XCTAssertTrue(progress.completedLessons.isEmpty)
        XCTAssertTrue(progress.completedUnits.isEmpty)
        XCTAssertNil(progress.lastStudyDate)
    }
    
    func testUserPreferencesInitialization() throws {
        let preferences = UserPreferences()
        
        XCTAssertEqual(preferences.studyGoal, .daily10Min)
        XCTAssertEqual(preferences.scriptDisplay, .both)
        XCTAssertEqual(preferences.preferredLanguage, "en")
        XCTAssertEqual(preferences.fontSize, 1.0)
        XCTAssertEqual(preferences.playbackSpeed, 1.0)
        XCTAssertTrue(preferences.soundEnabled)
        XCTAssertTrue(preferences.hapticsEnabled)
        XCTAssertTrue(preferences.notificationsEnabled)
    }
    
    // MARK: - Data Manager Tests
    
    func testDataManagerInitialization() throws {
        let dataManager = DataManager.shared
        
        // Test that seed data is loaded
        XCTAssertFalse(dataManager.chapters.isEmpty)
        XCTAssertFalse(dataManager.verses.isEmpty)
        XCTAssertFalse(dataManager.lessons.isEmpty)
        XCTAssertFalse(dataManager.exercises.isEmpty)
        
        // Test that review items are initialized
        XCTAssertFalse(dataManager.reviewItems.isEmpty)
    }
    
    func testVerseOfTheDay() throws {
        let dataManager = DataManager.shared
        let verseOfTheDay = dataManager.getVerseOfTheDay()
        
        XCTAssertNotNil(verseOfTheDay)
        XCTAssertTrue(dataManager.verses.contains { $0.id == verseOfTheDay?.id })
    }
    
    func testSearchFunctionality() throws {
        let dataManager = DataManager.shared
        
        // Test search by keyword
        let karmaResults = dataManager.searchVerses(query: "karma")
        XCTAssertFalse(karmaResults.isEmpty)
        
        // Test search by verse reference
        let referenceResults = dataManager.searchVerses(query: "2.47")
        XCTAssertFalse(referenceResults.isEmpty)
        
        // Test search by theme
        let themeResults = dataManager.searchVerses(query: "detachment")
        XCTAssertFalse(themeResults.isEmpty)
    }
    
    // MARK: - Exercise Type Tests
    
    func testExerciseTypeDisplayNames() throws {
        XCTAssertEqual(ExerciseType.readReveal.displayName, "Read & Reveal")
        XCTAssertEqual(ExerciseType.match.displayName, "Match")
        XCTAssertEqual(ExerciseType.fillBlank.displayName, "Fill in the Blank")
        XCTAssertEqual(ExerciseType.orderTokens.displayName, "Order the Verse")
        XCTAssertEqual(ExerciseType.multipleChoice.displayName, "Multiple Choice")
        XCTAssertEqual(ExerciseType.listening.displayName, "Listening")
    }
    
    // MARK: - Study Goal Tests
    
    func testStudyGoalProperties() throws {
        XCTAssertEqual(StudyGoal.daily5Min.durationMinutes, 5)
        XCTAssertEqual(StudyGoal.daily10Min.durationMinutes, 10)
        XCTAssertEqual(StudyGoal.weekendOnly.durationMinutes, 15)
        
        XCTAssertEqual(StudyGoal.daily5Min.displayName, "Daily 5 min")
        XCTAssertEqual(StudyGoal.daily10Min.displayName, "Daily 10 min")
        XCTAssertEqual(StudyGoal.weekendOnly.displayName, "Weekend only")
    }
    
    // MARK: - Script Display Tests
    
    func testScriptDisplayProperties() throws {
        XCTAssertEqual(ScriptDisplay.devanagari.displayName, "Devanagari")
        XCTAssertEqual(ScriptDisplay.iast.displayName, "IAST")
        XCTAssertEqual(ScriptDisplay.both.displayName, "Both")
    }
    
    // MARK: - Review Session Tests
    
    func testReviewSessionInitialization() throws {
        let items = [
            ReviewItem(id: "1", kind: .verse, payloadRef: "v1"),
            ReviewItem(id: "2", kind: .verse, payloadRef: "v2")
        ]
        
        var session = ReviewSession(items: items)
        
        XCTAssertEqual(session.items.count, 2)
        XCTAssertEqual(session.currentIndex, 0)
        XCTAssertFalse(session.isComplete)
        XCTAssertEqual(session.progress, 0.0)
        XCTAssertNotNil(session.currentItem)
    }
    
    func testReviewSessionProgress() throws {
        let items = [
            ReviewItem(id: "1", kind: .verse, payloadRef: "v1"),
            ReviewItem(id: "2", kind: .verse, payloadRef: "v2"),
            ReviewItem(id: "3", kind: .verse, payloadRef: "v3")
        ]
        
        var session = ReviewSession(items: items)
        
        // Test initial state
        XCTAssertEqual(session.progress, 0.0)
        XCTAssertFalse(session.isComplete)
        
        // Test after one item
        _ = session.submitAnswer("answer", for: items[0])
        XCTAssertEqual(session.progress, 1.0/3.0)
        XCTAssertFalse(session.isComplete)
        
        // Test after all items
        _ = session.submitAnswer("answer", for: items[1])
        _ = session.submitAnswer("answer", for: items[2])
        XCTAssertEqual(session.progress, 1.0)
        XCTAssertTrue(session.isComplete)
    }
    
    // MARK: - Performance Tests
    
    func testSearchPerformance() throws {
        let dataManager = DataManager.shared
        
        measure {
            for _ in 0..<100 {
                _ = dataManager.searchVerses(query: "karma")
            }
        }
    }
    
    func testSpacedRepetitionPerformance() throws {
        let manager = SpacedRepetitionManager()
        let items = (0..<1000).map { i in
            var item = ReviewItem(id: "\(i)", kind: .verse, payloadRef: "v\(i)")
            item.nextDueAt = Date().addingTimeInterval(TimeInterval(i))
            return item
        }
        
        measure {
            _ = manager.getDueItems(items)
        }
    }
}
