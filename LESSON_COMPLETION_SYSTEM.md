# Lesson Completion Tracking System

## Overview

A comprehensive lesson completion tracking system that captures detailed information about each lesson attempt, including scores, timing, and individual question responses.

## Database Table: `lesson_completions`

### Schema
```sql
CREATE TABLE lesson_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    attempt_number INTEGER NOT NULL DEFAULT 1,
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    score_percentage DECIMAL(5,2) NOT NULL,
    time_elapsed_seconds INTEGER NOT NULL,
    questions_answered JSONB, -- Individual question responses
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Key Features

1. **Attempt Tracking**: Each user can have multiple attempts per lesson
2. **Comprehensive Scoring**: Tracks score, total questions, and percentage
3. **Timing Data**: Records start time, completion time, and elapsed duration
4. **Question Details**: Stores individual question responses in JSONB format
5. **Performance Analytics**: Built-in functions for best score, average score, etc.

## Swift Models

### DBLessonCompletion
```swift
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
}
```

### DBLessonCompletionStats
```swift
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
}
```

## Database Functions

### get_next_attempt_number(user_id, lesson_id)
Returns the next attempt number for a user/lesson combination.

### get_best_lesson_score(user_id, lesson_id)
Returns the highest score percentage achieved for a lesson.

### get_average_lesson_score(user_id, lesson_id)
Returns the average score percentage across all attempts.

## Database Views

### lesson_completion_stats
Pre-computed statistics view that provides:
- Total attempts per lesson
- Best and average scores
- Fastest completion time
- Average completion time
- Last attempt date

## API Methods

### DatabaseService Methods

#### recordLessonCompletion()
```swift
func recordLessonCompletion(
    userId: UUID,
    lessonId: UUID,
    score: Int,
    totalQuestions: Int,
    timeElapsedSeconds: Int,
    questionsAnswered: [String: Any],
    startedAt: Date,
    completedAt: Date
) async throws -> DBLessonCompletion
```

#### getLessonCompletionStats()
```swift
func getLessonCompletionStats(userId: UUID, lessonId: UUID) async throws -> DBLessonCompletionStats?
```

#### getUserLessonCompletions()
```swift
func getUserLessonCompletions(userId: UUID, lessonId: UUID) async throws -> [DBLessonCompletion]
```

## Data Flow

1. **Quiz Start**: `lessonStartTime` is recorded when lesson begins
2. **Question Tracking**: Each answer is stored in `questionsAnswered` dictionary
3. **Quiz Completion**: Score, timing, and question data are collected
4. **Database Storage**: Comprehensive completion record is saved
5. **Analytics**: Statistics are available for performance tracking

## Question Response Format

Each question response is stored as:
```json
{
  "q1": {
    "question": "What is Arjuna's main concern?",
    "selectedAnswer": 1,
    "correctAnswer": 1,
    "isCorrect": true,
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"]
  }
}
```

## Security

- Row Level Security (RLS) enabled
- Users can only access their own completion records
- Proper authentication required for all operations

## Usage Example

```swift
// Record a lesson completion
let completion = try await databaseService.recordLessonCompletion(
    userId: currentUser.id,
    lessonId: lesson.id,
    score: 4,
    totalQuestions: 5,
    timeElapsedSeconds: 180,
    questionsAnswered: questionsAnswered,
    startedAt: lessonStartTime,
    completedAt: Date()
)

// Get completion statistics
let stats = try await databaseService.getLessonCompletionStats(
    userId: currentUser.id,
    lessonId: lesson.id
)
```

## Benefits

1. **Detailed Analytics**: Track learning progress over time
2. **Performance Insights**: Identify strengths and weaknesses
3. **Attempt History**: See improvement across multiple attempts
4. **Question Analysis**: Understand which questions are most challenging
5. **Timing Data**: Optimize lesson length and difficulty
6. **User Engagement**: Gamification through progress tracking
