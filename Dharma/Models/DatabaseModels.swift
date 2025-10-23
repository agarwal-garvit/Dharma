//
//  DatabaseModels.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation

// MARK: - Database Models (matching Supabase schema)

struct DBCourse: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let courseOrder: Int?
    let access: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, access
        case courseOrder = "course_order"
    }
}

struct DBLesson: Identifiable, Codable {
    let id: UUID
    let courseId: UUID
    let orderIdx: Int
    let title: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case orderIdx = "order_idx"
        case title
        case imageUrl = "image_url"
    }
}

enum LessonSectionKind: String, Codable, CaseIterable {
    case summary = "SUMMARY"
    case quiz = "QUIZ"
    case finalThoughts = "FINAL_THOUGHTS"
    case closingPrayer = "CLOSING_PRAYER"
    case report = "REPORT"
    
    var displayName: String {
        switch self {
        case .summary: return "Summary"
        case .quiz: return "Quiz"
        case .finalThoughts: return "Final Thoughts"
        case .closingPrayer: return "Closing Prayer"
        case .report: return "Report"
        }
    }
}

struct DBLessonSection: Identifiable, Codable {
    let id: UUID
    let lessonId: UUID
    let kind: LessonSectionKind
    let orderIdx: Int
    let content: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case lessonId = "lesson_id"
        case kind
        case orderIdx = "order_idx"
        case content
    }
}

enum DBQuizQuestionType: String, Codable, CaseIterable {
    case mcqSingle = "MCQ_SINGLE"
    case mcqMulti = "MCQ_MULTI"
    case trueFalse = "TRUEFALSE"
    
    var displayName: String {
        switch self {
        case .mcqSingle: return "Multiple Choice (Single)"
        case .mcqMulti: return "Multiple Choice (Multiple)"
        case .trueFalse: return "True/False"
        }
    }
}

struct DBQuizQuestion: Identifiable, Codable {
    let id: UUID
    let sectionId: UUID
    let idx: Int
    let stem: String
    let qtype: DBQuizQuestionType
    let explanation: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sectionId = "section_id"
        case idx
        case stem
        case qtype
        case explanation
    }
}

struct DBQuizOption: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    let idx: Int
    let optionText: String
    let isCorrect: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case idx
        case optionText = "option_text"
        case isCorrect = "is_correct"
    }
}

// MARK: - User Progress Models

enum LessonProgressStatus: String, Codable, CaseIterable {
    case notStarted = "NOT_STARTED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    
    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }
}

// Legacy model - no longer used, derived from lesson_completions instead
struct DBUserLessonProgress: Codable {
    let userId: UUID
    let lessonId: UUID
    let status: LessonProgressStatus
    let startedAt: String?
    let completedAt: String?
    let lastSeenAt: String?
    let lastScorePct: Double?
    let bestScorePct: Double?
    let totalCompletions: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case lessonId = "lesson_id"
        case status
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case lastSeenAt = "last_seen_at"
        case lastScorePct = "last_score_pct"
        case bestScorePct = "best_score_pct"
        case totalCompletions = "total_completions"
    }
}

// Simplified progress model derived from lesson_completions
struct DBLessonProgress: Codable {
    let lessonId: UUID
    let bestScorePercentage: Double
    let lastScorePercentage: Double
    let totalAttempts: Int
    let lastCompletedAt: String
    
    enum CodingKeys: String, CodingKey {
        case lessonId = "lesson_id"
        case bestScorePercentage = "best_score_percentage"
        case lastScorePercentage = "last_score_percentage"
        case totalAttempts = "total_attempts"
        case lastCompletedAt = "last_completed_at"
    }
}

struct DBUserLessonSession: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let lessonId: UUID
    let startedAt: String
    let completedAt: String?
    let durationSeconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lessonId = "lesson_id"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case durationSeconds = "duration_seconds"
    }
}

struct DBUserQuizAttempt: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let lessonId: UUID
    let startedAt: String
    let submittedAt: String?
    let scorePct: Double?
    let durationSeconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lessonId = "lesson_id"
        case startedAt = "started_at"
        case submittedAt = "submitted_at"
        case scorePct = "score_pct"
        case durationSeconds = "duration_seconds"
    }
}

struct DBUserQuizAnswer: Codable {
    let attemptId: UUID
    let questionId: UUID
    let optionId: UUID
    let isCorrect: Bool
    
    enum CodingKeys: String, CodingKey {
        case attemptId = "attempt_id"
        case questionId = "question_id"
        case optionId = "option_id"
        case isCorrect = "is_correct"
    }
}

struct DBUserStats: Codable {
    let userId: UUID
    let xpTotal: Int
    let streakCount: Int
    let longestStreak: Int
    let lastActiveDate: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case xpTotal = "xp_total"
        case streakCount = "streak_count"
        case longestStreak = "longest_streak"
        case lastActiveDate = "last_active_date"
    }
}

struct DBLessonCompletion: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let lessonId: UUID
    let attemptNumber: Int
    let score: Int
    let totalQuestions: Int
    let scorePercentage: Double
    let timeElapsedSeconds: Int
    let questionsAnswered: [String: AnyCodable]?
    let startedAt: String
    let completedAt: String
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lessonId = "lesson_id"
        case attemptNumber = "attempt_number"
        case score
        case totalQuestions = "total_questions"
        case scorePercentage = "score_percentage"
        case timeElapsedSeconds = "time_elapsed_seconds"
        case questionsAnswered = "questions_answered"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBLessonCompletionStats: Codable {
    let userId: UUID
    let lessonId: UUID
    let lessonTitle: String
    let totalAttempts: Int
    let bestScore: Double
    let averageScore: Double
    let fastestCompletion: Int
    let averageCompletionTime: Double
    let lastAttemptDate: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case lessonId = "lesson_id"
        case lessonTitle = "lesson_title"
        case totalAttempts = "total_attempts"
        case bestScore = "best_score"
        case averageScore = "average_score"
        case fastestCompletion = "fastest_completion"
        case averageCompletionTime = "average_completion_time"
        case lastAttemptDate = "last_attempt_date"
    }
}

struct DBXPEvent: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let lessonId: UUID?
    let ruleCode: String
    let awardedXp: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lessonId = "lesson_id"
        case ruleCode = "rule_code"
        case awardedXp = "awarded_xp"
        case createdAt = "created_at"
    }
}

struct DBXPRule: Codable {
    let code: String
    let xpAmount: Int
    
    enum CodingKeys: String, CodingKey {
        case code
        case xpAmount = "xp_amount"
    }
}

// MARK: - Daily Usage Models

struct DBDailyUsage: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let usageDate: String
    let sessionCount: Int
    let totalTimeSeconds: Int
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case usageDate = "date"
        case sessionCount = "session_count"
        case totalTimeSeconds = "total_time_seconds"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Lives Models

struct DBUserLives: Codable {
    let userId: UUID
    var currentLives: Int
    var life1RegeneratesAt: String?
    var life2RegeneratesAt: String?
    var life3RegeneratesAt: String?
    var life4RegeneratesAt: String?
    var life5RegeneratesAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentLives = "current_lives"
        case life1RegeneratesAt = "life_1_regenerates_at"
        case life2RegeneratesAt = "life_2_regenerates_at"
        case life3RegeneratesAt = "life_3_regenerates_at"
        case life4RegeneratesAt = "life_4_regenerates_at"
        case life5RegeneratesAt = "life_5_regenerates_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Login Session Models

struct DBUserLoginSession: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let loginTimestamp: String
    let sessionDurationSeconds: Int?
    let deviceModel: String?
    let deviceOS: String?
    let appVersion: String?
    let locationCountry: String?
    let locationCity: String?
    let authMethod: String?
    let ipAddress: String?
    let isFirstLogin: Bool?
    let userTimezone: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case loginTimestamp = "login_timestamp"
        case sessionDurationSeconds = "session_duration_seconds"
        case deviceModel = "device_model"
        case deviceOS = "device_os"
        case appVersion = "app_version"
        case locationCountry = "location_country"
        case locationCity = "location_city"
        case authMethod = "auth_method"
        case ipAddress = "ip_address"
        case isFirstLogin = "is_first_login"
        case userTimezone = "user_timezone"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DBUserLoginStats: Codable {
    let totalLogins: Int
    let firstLogin: String?
    let lastLogin: String?
    let mostUsedDevice: String?
    let mostUsedAuthMethod: String?
    let averageSessionDurationMinutes: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalLogins = "total_logins"
        case firstLogin = "first_login"
        case lastLogin = "last_login"
        case mostUsedDevice = "most_used_device"
        case mostUsedAuthMethod = "most_used_auth_method"
        case averageSessionDurationMinutes = "average_session_duration_minutes"
    }
}

struct DBUserMetrics: Codable {
    let totalXp: Int
    let currentStreak: Int
    let longestStreak: Int
    let lessonsCompleted: Int
    let totalStudyTimeMinutes: Int
    let quizAverageScore: Double
    
    enum CodingKeys: String, CodingKey {
        case totalXp = "total_xp"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case lessonsCompleted = "lessons_completed"
        case totalStudyTimeMinutes = "total_study_time_minutes"
        case quizAverageScore = "quiz_average_score"
    }
}

// MARK: - Helper Types

// Helper type to handle Any JSON values from the database
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let array = value as? [Any] {
            try container.encode(array.map { AnyCodable($0) })
        } else if let dict = value as? [String: Any] {
            try container.encode(dict.mapValues { AnyCodable($0) })
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

// MARK: - Combined Models for App Use

struct CourseWithLessons: Identifiable {
    let course: DBCourse
    let lessons: [DBLesson]
    
    var id: UUID { course.id }
}

struct LessonWithSections: Identifiable {
    let lesson: DBLesson
    let sections: [DBLessonSection]
    
    var id: UUID { lesson.id }
}

struct SectionWithQuestions: Identifiable {
    let section: DBLessonSection
    let questions: [DBQuizQuestion]
    
    var id: UUID { section.id }
}

struct QuestionWithOptions: Identifiable {
    let question: DBQuizQuestion
    let options: [DBQuizOption]
    
    var id: UUID { question.id }
}
