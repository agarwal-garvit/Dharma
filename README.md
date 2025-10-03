# Dharma - Spiritual Learning iOS App

A comprehensive iOS application for learning spiritual texts, particularly the Bhagavad Gita, with interactive lessons, quizzes, and AI-powered chat functionality.

## 📱 Overview

Dharma is a modern iOS app built with SwiftUI that provides an immersive learning experience for spiritual texts. The app features a beautiful staggered card layout, interactive lessons, spaced repetition learning, and an AI chatbot for spiritual guidance.

## 🏗️ Project Structure

```
Dharma/
├── Dharma/                          # Main iOS app source code
│   ├── Assets.xcassets/            # App icons, images, and visual assets
│   │   ├── downLeft.imageset/      # Custom arrow images for lesson flow
│   │   ├── downRight.imageset/     # Custom arrow images for lesson flow
│   │   └── google_logo.imageset/   # Google authentication logo
│   │
│   ├── Configuration/              # App configuration and environment setup
│   │   └── Config.swift           # Supabase, OpenAI, and Google API configuration
│   │
│   ├── Managers/                   # Core business logic and data management
│   │   ├── DataManager.swift      # Main data orchestrator and Supabase integration
│   │   ├── DatabaseService.swift  # Supabase database operations
│   │   ├── AuthManager.swift      # User authentication (Google OAuth)
│   │   ├── ChatManager.swift      # AI chatbot functionality
│   │   ├── AudioManager.swift     # Audio playback for lessons
│   │   ├── HapticManager.swift    # Haptic feedback
│   │   └── ThemeManager.swift     # App theming and colors
│   │
│   ├── Models/                     # Data models and structures
│   │   ├── DatabaseModels.swift   # Supabase database models (DBCourse, DBLesson, etc.)
│   │   ├── DataModels.swift       # Legacy app models (Chapter, Lesson, etc.)
│   │   └── SpacedRepetition.swift # Spaced repetition algorithm
│   │
│   ├── Views/                      # SwiftUI user interface components
│   │   ├── Auth/                  # Authentication screens
│   │   ├── Home/                  # Home dashboard
│   │   ├── Learn/                 # Learning interface with staggered cards
│   │   ├── Chatbot/               # AI chat interface
│   │   ├── Profile/               # User profile and settings
│   │   ├── Progress/              # Learning progress tracking
│   │   ├── Review/                # Spaced repetition review
│   │   └── Components/            # Reusable UI components
│   │
│   ├── DharmaApp.swift            # Main app entry point
│   └── ContentView.swift          # Root content view
│
├── database_setup.sql             # Supabase database schema setup
├── populate_lessons_data.sql      # Sample data for Bhagavad Gita lessons
├── ENVIRONMENT_SETUP.md           # Environment configuration guide
├── SETUP_INSTRUCTIONS.md          # Development setup instructions
└── README.md                      # This file
```

## 🗄️ Database Architecture (Supabase)

### Core Tables

#### 1. **courses**
```sql
- id (UUID, Primary Key)
- title (TEXT) - Course name (e.g., "Bhagavad Gita")
- description (TEXT) - Course description
```

#### 2. **lessons**
```sql
- id (UUID, Primary Key)
- course_id (UUID, Foreign Key) - References courses.id
- order_idx (INTEGER) - Lesson order within course
- title (TEXT) - Lesson/chapter title
```

#### 3. **lesson_sections**
```sql
- id (UUID, Primary Key)
- lesson_id (UUID, Foreign Key) - References lessons.id
- kind (TEXT) - Section type: SUMMARY, QUIZ, FINAL_THOUGHTS, CLOSING_PRAYER, REPORT
- content (JSONB) - Flexible content storage
- order_idx (INTEGER) - Section order within lesson
```

#### 4. **quiz_questions**
```sql
- id (UUID, Primary Key)
- lesson_id (UUID, Foreign Key) - References lessons.id
- question (TEXT) - Quiz question text
- order_idx (INTEGER) - Question order
```

#### 5. **quiz_options**
```sql
- id (UUID, Primary Key)
- question_id (UUID, Foreign Key) - References quiz_questions.id
- text (TEXT) - Answer option text
- is_correct (BOOLEAN) - Whether this option is correct
- order_idx (INTEGER) - Option order
```

#### 6. **chat_conversations**
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key) - References auth.users.id
- title (TEXT) - Conversation title
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
- message_count (INTEGER)
```

#### 7. **chat_messages**
```sql
- id (UUID, Primary Key)
- conversation_id (UUID, Foreign Key) - References chat_conversations.id
- content (TEXT) - Message content
- is_user (BOOLEAN) - True for user messages, false for AI
- timestamp (TIMESTAMPTZ)
```

#### 8. **xp_rules**
```sql
- code (TEXT, Primary Key) - XP rule identifier
- xp_amount (INTEGER) - XP points awarded
```

## 🔌 Supabase Integration

### Configuration
The app connects to Supabase using configuration in `Config.swift`:

```swift
static var supabaseURL: String = "YOUR_SUPABASE_URL_HERE"
static var supabaseKey: String = "YOUR_SUPABASE_ANON_KEY_HERE"
```

### Data Flow

#### 1. **Course and Lesson Loading**
```swift
// DataManager.swift
await loadCourses()           // Loads all courses from Supabase
await loadLessons(for: courseId)  // Loads lessons for specific course
```

#### 2. **Lesson Content Loading**
```swift
// Loads lesson sections (summary, quiz, etc.) from database
let sections = await loadLessonSections(for: lessonId)
```

#### 3. **User Progress Tracking**
- User progress is stored locally but can be synced to Supabase
- XP points are calculated based on `xp_rules` table
- Spaced repetition data is managed locally

#### 4. **Chat Functionality**
```swift
// ChatManager.swift
- Creates conversations in chat_conversations table
- Stores messages in chat_messages table
- Integrates with OpenAI for AI responses
```

## 🎨 Key Features

### 1. **Staggered Lesson Layout**
- Beautiful zigzag card layout with alternating left/right positioning
- Custom arrow images (`downLeft.png`, `downRight.png`) showing lesson flow
- Fixed course title that updates based on visible lessons
- Light blue color scheme with orange accents

### 2. **Interactive Learning**
- Chapter summaries with spiritual content
- Interactive quizzes with multiple choice questions
- Final thoughts and closing prayers
- Progress tracking and XP system

### 3. **AI Chatbot**
- Spiritual guidance and Q&A
- Conversation history stored in Supabase
- OpenAI integration for intelligent responses
- Context-aware spiritual advice

### 4. **Spaced Repetition**
- Algorithm-based review scheduling
- Optimized learning retention
- Progress tracking and statistics

### 5. **Authentication**
- Google OAuth integration
- Secure user management
- Profile customization

## 🚀 Setup Instructions

### 1. **Environment Setup**
```bash
# Copy environment template
cp env.example .env

# Run setup script
./setup_env_vars.sh
```

### 2. **Database Setup**
1. Create a Supabase project
2. Run `database_setup.sql` in Supabase SQL editor
3. Run `populate_lessons_data.sql` to add sample data
4. Update `Config.swift` with your Supabase credentials

### 3. **API Keys**
- **Supabase**: Get URL and anon key from your project settings
- **OpenAI**: Add your API key for chat functionality
- **Google OAuth**: Configure Google Sign-In in Google Cloud Console

### 4. **iOS Development**
```bash
# Open project in Xcode
open Dharma.xcodeproj

# Install dependencies (handled by Swift Package Manager)
# Build and run on simulator or device
```

## 📱 App Architecture

### Data Flow
```
Supabase Database
    ↓
DatabaseService (Supabase client)
    ↓
DataManager (Business logic)
    ↓
SwiftUI Views (User interface)
```

### Key Components

#### **DataManager**
- Central data orchestrator
- Manages both database and legacy models
- Handles loading states and error management
- Coordinates between different data sources

#### **DatabaseService**
- Direct Supabase integration
- Handles all database operations
- Manages authentication state
- Provides reactive data updates

#### **LearnView**
- Main learning interface
- Implements staggered card layout
- Manages course title updates
- Handles lesson navigation

## 🔧 Development Notes

### Database Models
The app uses two sets of models:
- **DatabaseModels**: Direct mapping to Supabase schema (`DBCourse`, `DBLesson`, etc.)
- **DataModels**: Legacy models for backward compatibility (`Chapter`, `Lesson`, etc.)

### Migration Strategy
The app is designed to gradually migrate from hardcoded data to database-driven content while maintaining backward compatibility.

### Performance Considerations
- Lazy loading of lesson content
- Efficient image caching for arrow assets
- Optimized database queries with proper indexing
- Local caching for frequently accessed data

## 🎯 Future Enhancements

1. **Multiple Courses**: Support for Mahabharata, Upanishads, etc.
2. **Offline Mode**: Download lessons for offline learning
3. **Social Features**: Share progress, leaderboards
4. **Advanced Analytics**: Detailed learning insights
5. **Voice Integration**: Audio lessons and pronunciation guides

## 📄 License

This project is proprietary software. All rights reserved.

## 🤝 Contributing

For development questions or contributions, please contact the development team.

---

*Built with ❤️ for spiritual learning and growth*