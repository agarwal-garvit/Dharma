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
    }
    
    // MARK: - Course Operations
    
    func fetchAllCourses() async throws -> [DBCourse] {
        isLoading = true
        errorMessage = nil
        
        do {
            let courses: [DBCourse] = try await supabase.database
                .from("courses")
                .select()
                .order("title")
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
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
}
