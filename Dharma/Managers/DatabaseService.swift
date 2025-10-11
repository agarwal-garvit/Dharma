//
//  DatabaseService.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import Supabase
import Combine

@MainActor
class DatabaseService: ObservableObject {
    static let shared = DatabaseService()
    
    private let supabase: SupabaseClient
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        self.supabase = SupabaseClient(
            supabaseURL: Config.supabaseURLObject,
            supabaseKey: Config.supabaseKey
        )
        
        // Debug configuration
        print("🔧 DatabaseService initialized")
        print("📍 Supabase URL: \(Config.supabaseURL)")
        print("🔑 Supabase Key: \(Config.supabaseKey.prefix(20))...")
    }
    
    // MARK: - Course Operations
    
    func fetchAllCourses() async throws -> [DBCourse] {
        isLoading = true
        errorMessage = nil
        
        do {
            let courses: [DBCourse] = try await supabase.database
                .from("courses")
                .select()
                .order("course_order")
                .execute()
                .value
            
            isLoading = false
            return courses
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch courses: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchCourse(by id: UUID) async throws -> DBCourse {
        isLoading = true
        errorMessage = nil
        
        do {
            let course: DBCourse = try await supabase.database
                .from("courses")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            isLoading = false
            return course
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch course: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Lesson Operations
    
    func fetchLessons(for courseId: UUID) async throws -> [DBLesson] {
        isLoading = true
        errorMessage = nil
        
        do {
            let lessons: [DBLesson] = try await supabase.database
                .from("lessons")
                .select()
                .eq("course_id", value: courseId)
                .order("order_idx")
                .execute()
                .value
            
            isLoading = false
            return lessons
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch lessons: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchLesson(by id: UUID) async throws -> DBLesson {
        isLoading = true
        errorMessage = nil
        
        do {
            let lesson: DBLesson = try await supabase.database
                .from("lessons")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            isLoading = false
            return lesson
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch lesson: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Lesson Section Operations
    
    func fetchLessonSections(for lessonId: UUID) async throws -> [DBLessonSection] {
        isLoading = true
        errorMessage = nil
        
        do {
            let sections: [DBLessonSection] = try await supabase.database
                .from("lesson_sections")
                .select()
                .eq("lesson_id", value: lessonId)
                .order("order_idx")
                .execute()
                .value
            
            isLoading = false
            return sections
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch lesson sections: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Quiz Operations
    
    func fetchQuizContent(for sectionId: UUID) async throws -> QuizContent {
        isLoading = true
        errorMessage = nil
        
        do {
            let section: DBLessonSection = try await supabase.database
                .from("lesson_sections")
                .select()
                .eq("id", value: sectionId)
                .single()
                .execute()
                .value
            
            guard let content = section.content,
                  let title = content["title"]?.value as? String,
                  let questionsData = content["questions"]?.value else {
                throw NSError(domain: "QuizError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid quiz content format"])
            }
            
            // Parse questions from JSON
            let questions = try parseQuizQuestions(from: questionsData)
            
            isLoading = false
            return QuizContent(title: title, questions: questions)
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch quiz content: \(error.localizedDescription)"
            throw error
        }
    }
    
    private func parseQuizQuestions(from data: Any) throws -> [QuizQuestion] {
        guard let questionsArray = data as? [[String: Any]] else {
            throw NSError(domain: "QuizError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Questions must be an array"])
        }
        
        var questions: [QuizQuestion] = []
        
        for questionData in questionsArray {
            guard let id = questionData["id"] as? String,
                  let question = questionData["question"] as? String,
                  let typeString = questionData["type"] as? String,
                  let type = JSONQuizQuestionType(rawValue: typeString),
                  let options = questionData["options"] as? [String],
                  let correctAnswer = questionData["correctAnswer"] as? Int,
                  let explanation = questionData["explanation"] as? String else {
                throw NSError(domain: "QuizError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid question format"])
            }
            
            let quizQuestion = QuizQuestion(
                id: id,
                question: question,
                type: type,
                options: options,
                correctAnswer: correctAnswer,
                explanation: explanation
            )
            questions.append(quizQuestion)
        }
        
        return questions
    }
    
    // Legacy methods for backward compatibility
    func fetchQuizQuestions(for sectionId: UUID) async throws -> [DBQuizQuestion] {
        isLoading = true
        errorMessage = nil
        
        do {
            let questions: [DBQuizQuestion] = try await supabase.database
                .from("quiz_questions")
                .select()
                .eq("section_id", value: sectionId)
                .order("idx")
                .execute()
                .value
            
            isLoading = false
            return questions
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch quiz questions: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchQuizOptions(for questionId: UUID) async throws -> [DBQuizOption] {
        isLoading = true
        errorMessage = nil
        
        do {
            let options: [DBQuizOption] = try await supabase.database
                .from("quiz_options")
                .select()
                .eq("question_id", value: questionId)
                .order("idx")
                .execute()
                .value
            
            isLoading = false
            return options
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch quiz options: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Lesson Completion Operations
    
    func recordLessonCompletion(
        userId: UUID,
        lessonId: UUID,
        score: Int,
        totalQuestions: Int,
        timeElapsedSeconds: Int,
        questionsAnswered: [String: Any],
        startedAt: Date,
        completedAt: Date
    ) async throws -> DBLessonCompletion {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get next attempt number
            let attemptNumber = try await getNextAttemptNumber(userId: userId, lessonId: lessonId)
            
            let scorePercentage = Double(score) / Double(totalQuestions) * 100
            
            let completion = DBLessonCompletion(
                id: UUID(),
                userId: userId,
                lessonId: lessonId,
                attemptNumber: attemptNumber,
                score: score,
                totalQuestions: totalQuestions,
                scorePercentage: scorePercentage,
                timeElapsedSeconds: timeElapsedSeconds,
                questionsAnswered: questionsAnswered.mapValues { AnyCodable($0) },
                startedAt: ISO8601DateFormatter().string(from: startedAt),
                completedAt: ISO8601DateFormatter().string(from: completedAt),
                createdAt: nil,
                updatedAt: nil
            )
            
            // Insert the lesson completion and return the inserted record
            let result: DBLessonCompletion = try await supabase.database
                .from("lesson_completions")
                .insert(completion)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ Lesson completion insert and fetch successful")
            
            isLoading = false
            print("✅ Lesson completion recorded: \(score)/\(totalQuestions) (\(String(format: "%.1f", scorePercentage))%) in \(timeElapsedSeconds)s")
            
            // Award XP based on performance
            await awardLessonCompletionXP(userId: userId, scorePercentage: scorePercentage)
            
            return result
        } catch {
            isLoading = false
            errorMessage = "Failed to record lesson completion: \(error.localizedDescription)"
            print("❌ DatabaseService.recordLessonCompletion error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error details: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getNextAttemptNumber(userId: UUID, lessonId: UUID) async throws -> Int {
        do {
            let result: [String: Int] = try await supabase.database
                .rpc("get_next_attempt_number", params: [
                    "p_user_id": userId.uuidString,
                    "p_lesson_id": lessonId.uuidString
                ])
                .execute()
                .value
            
            return result["get_next_attempt_number"] ?? 1
        } catch {
            // Fallback: manually count attempts
            let completions: [DBLessonCompletion] = try await supabase.database
                .from("lesson_completions")
                .select("attempt_number")
                .eq("user_id", value: userId)
                .eq("lesson_id", value: lessonId)
                .order("attempt_number", ascending: false)
                .limit(1)
                .execute()
                .value
            
            return (completions.first?.attemptNumber ?? 0) + 1
        }
    }
    
    func getLessonCompletionStats(userId: UUID, lessonId: UUID) async throws -> DBLessonCompletionStats? {
        isLoading = true
        errorMessage = nil
        
        do {
            let stats: [DBLessonCompletionStats] = try await supabase.database
                .from("lesson_completion_stats")
                .select()
                .eq("user_id", value: userId)
                .eq("lesson_id", value: lessonId)
                .execute()
                .value
            
            isLoading = false
            return stats.first
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch lesson completion stats: \(error.localizedDescription)"
            throw error
        }
    }
    
    func getUserLessonCompletions(userId: UUID, lessonId: UUID) async throws -> [DBLessonCompletion] {
        isLoading = true
        errorMessage = nil
        
        do {
            let completions: [DBLessonCompletion] = try await supabase.database
                .from("lesson_completions")
                .select()
                .eq("user_id", value: userId)
                .eq("lesson_id", value: lessonId)
                .order("attempt_number", ascending: true)
                .execute()
                .value
            
            isLoading = false
            return completions
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch lesson completions: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Combined Operations
    
    func fetchCourseWithLessons(courseId: UUID) async throws -> CourseWithLessons {
        async let course = fetchCourse(by: courseId)
        async let lessons = fetchLessons(for: courseId)
        
        let (fetchedCourse, fetchedLessons) = try await (course, lessons)
        return CourseWithLessons(course: fetchedCourse, lessons: fetchedLessons)
    }
    
    func fetchLessonWithSections(lessonId: UUID) async throws -> LessonWithSections {
        async let lesson = fetchLesson(by: lessonId)
        async let sections = fetchLessonSections(for: lessonId)
        
        let (fetchedLesson, fetchedSections) = try await (lesson, sections)
        return LessonWithSections(lesson: fetchedLesson, sections: fetchedSections)
    }
    
    func fetchSectionWithQuestions(sectionId: UUID) async throws -> SectionWithQuestions {
        async let questions = fetchQuizQuestions(for: sectionId)
        
        // We need to get the section first
        let section: DBLessonSection = try await supabase.database
            .from("lesson_sections")
            .select()
            .eq("id", value: sectionId)
            .single()
            .execute()
            .value
        
        let fetchedQuestions = try await questions
        return SectionWithQuestions(section: section, questions: fetchedQuestions)
    }
    
    @MainActor
    func fetchQuestionWithOptions(questionId: UUID) async throws -> QuestionWithOptions {
        async let question: DBQuizQuestion = supabase.database
            .from("quiz_questions")
            .select()
            .eq("id", value: questionId)
            .single()
            .execute()
            .value
        
        async let options = fetchQuizOptions(for: questionId)
        
        let (fetchedQuestion, fetchedOptions) = try await (question, options)
        return QuestionWithOptions(question: fetchedQuestion, options: fetchedOptions)
    }
    
    // MARK: - User Progress Operations
    
    func fetchUserLessonProgress(userId: UUID, lessonId: UUID) async throws -> DBUserLessonProgress? {
        do {
            let progress: [DBUserLessonProgress] = try await supabase.database
                .from("user_lesson_progress")
                .select()
                .eq("user_id", value: userId)
                .eq("lesson_id", value: lessonId)
                .execute()
                .value
            
            return progress.first
        } catch {
            errorMessage = "Failed to fetch user lesson progress: \(error.localizedDescription)"
            throw error
        }
    }
    
    func updateUserLessonProgress(_ progress: DBUserLessonProgress) async throws {
        do {
            try await supabase.database
                .from("user_lesson_progress")
                .upsert(progress)
                .execute()
        } catch {
            errorMessage = "Failed to update user lesson progress: \(error.localizedDescription)"
            throw error
        }
    }
    
    func startLessonSession(userId: UUID, lessonId: UUID) async throws -> DBUserLessonSession {
        let session = DBUserLessonSession(
            id: UUID(),
            userId: userId,
            lessonId: lessonId,
            startedAt: ISO8601DateFormatter().string(from: Date()),
            completedAt: nil,
            durationSeconds: nil
        )
        
        do {
            try await supabase.database
                .from("user_lesson_sessions")
                .insert(session)
                .execute()
            
            return session
        } catch {
            errorMessage = "Failed to start lesson session: \(error.localizedDescription)"
            throw error
        }
    }
    
    func completeLessonSession(_ sessionId: UUID, durationSeconds: Int) async throws {
        do {
            try await supabase.database
                .from("user_lesson_sessions")
                .update([
                    "completed_at": ISO8601DateFormatter().string(from: Date()),
                    "duration_seconds": String(durationSeconds)
                ])
                .eq("id", value: sessionId)
                .execute()
        } catch {
            errorMessage = "Failed to complete lesson session: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Quiz Attempt Operations
    
    func startQuizAttempt(userId: UUID, lessonId: UUID) async throws -> DBUserQuizAttempt {
        let attempt = DBUserQuizAttempt(
            id: UUID(),
            userId: userId,
            lessonId: lessonId,
            startedAt: ISO8601DateFormatter().string(from: Date()),
            submittedAt: nil,
            scorePct: nil,
            durationSeconds: nil
        )
        
        do {
            try await supabase.database
                .from("user_quiz_attempts")
                .insert(attempt)
                .execute()
            
            return attempt
        } catch {
            errorMessage = "Failed to start quiz attempt: \(error.localizedDescription)"
            throw error
        }
    }
    
    func submitQuizAttempt(_ attemptId: UUID, answers: [DBUserQuizAnswer], scorePct: Double, durationSeconds: Int) async throws {
        do {
            // Update the attempt
            try await supabase.database
                .from("user_quiz_attempts")
                .update([
                    "submitted_at": ISO8601DateFormatter().string(from: Date()),
                    "score_pct": String(scorePct),
                    "duration_seconds": String(durationSeconds)
                ])
                .eq("id", value: attemptId)
                .execute()
            
            // Insert the answers
            if !answers.isEmpty {
                try await supabase.database
                    .from("user_quiz_answers")
                    .insert(answers)
                    .execute()
            }
        } catch {
            errorMessage = "Failed to submit quiz attempt: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - XP Operations
    
    func awardXP(userId: UUID, lessonId: UUID?, ruleCode: String, xpAmount: Int) async throws {
        let xpEvent = DBXPEvent(
            id: UUID(),
            userId: userId,
            lessonId: lessonId,
            ruleCode: ruleCode,
            awardedXp: xpAmount,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        do {
            try await supabase.database
                .from("xp_events")
                .insert(xpEvent)
                .execute()
            
            // Update user stats
            try await supabase.database
                .from("user_stats")
                .upsert([
                    "user_id": userId.uuidString,
                    "xp_total": String(xpAmount)
                ])
                .execute()
        } catch {
            errorMessage = "Failed to award XP: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchUserStats(userId: UUID) async throws -> DBUserStats? {
        do {
            let stats: [DBUserStats] = try await supabase.database
                .from("user_stats")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return stats.first
        } catch {
            errorMessage = "Failed to fetch user stats: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Daily Usage Operations
    
    func recordDailyUsage(userId: UUID, sessionTimeSeconds: Int = 0) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.database
                .rpc("record_daily_usage", params: [
                    "p_user_id": userId.uuidString,
                    "p_usage_date": DateFormatter.dateOnly.string(from: Date()),
                    "p_session_time_seconds": String(sessionTimeSeconds)
                ])
                .execute()
            
            isLoading = false
            print("✅ Daily usage recorded for user: \(userId)")
        } catch {
            isLoading = false
            errorMessage = "Failed to record daily usage: \(error.localizedDescription)"
            throw error
        }
    }
    
    func getUserMetrics(userId: UUID) async throws -> DBUserMetrics? {
        isLoading = true
        errorMessage = nil
        
        do {
            let metrics: [DBUserMetrics] = try await supabase.database
                .rpc("get_user_metrics", params: [
                    "p_user_id": userId.uuidString
                ])
                .execute()
                .value
            
            isLoading = false
            return metrics.first
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch user metrics: \(error.localizedDescription)"
            throw error
        }
    }
    
    func calculateUserStreak(userId: UUID) async throws -> Int {
        do {
            let result: [String: Int] = try await supabase.database
                .rpc("calculate_user_streak", params: [
                    "p_user_id": userId.uuidString
                ])
                .execute()
                .value
            
            return result["calculate_user_streak"] ?? 0
        } catch {
            errorMessage = "Failed to calculate user streak: \(error.localizedDescription)"
            throw error
        }
    }
    
    func awardStreakMilestoneXP(userId: UUID, streakDays: Int) async throws -> Int {
        do {
            let result: [String: Int] = try await supabase.database
                .rpc("award_streak_milestone_xp", params: [
                    "p_user_id": userId.uuidString,
                    "p_streak_days": String(streakDays)
                ])
                .execute()
                .value
            
            let xpAwarded = result["award_streak_milestone_xp"] ?? 0
            if xpAwarded > 0 {
                print("🎉 Awarded \(xpAwarded) XP for \(streakDays) day streak!")
            }
            return xpAwarded
        } catch {
            errorMessage = "Failed to award streak milestone XP: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchDailyUsage(userId: UUID) async throws -> [DBDailyUsage] {
        do {
            let usage: [DBDailyUsage] = try await supabase.database
                .from("daily_usage")
                .select()
                .eq("user_id", value: userId)
                .order("date", ascending: false)
                .limit(30)
                .execute()
                .value
            
            return usage
        } catch {
            errorMessage = "Failed to fetch daily usage: \(error.localizedDescription)"
            throw error
        }
    }
    
    private func awardLessonCompletionXP(userId: UUID, scorePercentage: Double) async {
        do {
            // Base XP for completing a lesson
            var baseXP = 25
            
            // Bonus XP based on score
            var bonusXP = 0
            if scorePercentage >= 90 {
                bonusXP = 15 // Perfect score bonus
            } else if scorePercentage >= 80 {
                bonusXP = 10 // Good score bonus
            } else if scorePercentage >= 70 {
                bonusXP = 5 // Decent score bonus
            }
            
            let totalXP = baseXP + bonusXP
            
            // Award XP
            try await awardXP(userId: userId, lessonId: nil, ruleCode: "LESSON_COMPLETION", xpAmount: totalXP)
            
            print("🎯 Awarded \(totalXP) XP for lesson completion (Score: \(String(format: "%.1f", scorePercentage))%)")
        } catch {
            print("Failed to award lesson completion XP: \(error)")
        }
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
