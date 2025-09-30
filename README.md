# Dharma - Bhagavad Gita Learning App

A production-ready SwiftUI iOS app for learning the Bhagavad Gita, inspired by Duolingo's approach to language learning. Dharma combines daily scripture study with skill-tree lessons, bite-sized practice, and spaced repetition to make learning effortless and engaging.

## Features

### 📚 Learn Tab
- **Interactive Lessons**: Server-fetched content with progressive skill tree
- **Mixed Exercise Types**: Read & Reveal, Match, Fill-in-the-blank, Multiple Choice, Listening
- **Lesson Player**: Interactive exercises with immediate feedback
- **Progress Tracking**: Visual progress indicators and completion states

### 📜 Bhagavad Gita Tab
- **Complete Text Access**: All 18 chapters with verse-by-verse navigation
- **Multiple Scripts**: Devanagari, IAST transliteration, and English translation
- **Audio Playback**: High-quality audio with TTS fallback
- **Search Functionality**: Find verses by reference, keywords, or themes

### 🐄 Progress & Pet Tab
- **Spiritual Companion**: Care for your cow pet (Gau Mata) representing your progress
- **Pet Care System**: Feed, play, and meditate with your pet to increase happiness
- **Progress Visualization**: XP, streaks, study time, and achievements
- **Growth Tracking**: Pet level and happiness reflect your learning journey

### 🏆 Leaderboard Tab
- **Coming Soon**: Global rankings and competition features
- **Progress Comparison**: Compare your journey with other learners
- **Achievement System**: Unlockable badges and recognition
- **Study Groups**: Compete with friends and family

### 💬 Chatbot Tab
- **AI Gita Guide**: Ask questions about the Bhagavad Gita
- **Intelligent Responses**: Context-aware answers about verses, concepts, and teachings
- **Conversational Interface**: Natural chat experience with suggested questions
- **Learning Support**: Get help understanding complex concepts

## Technical Architecture

### Core Components

#### Data Models
- `Verse`: Core scripture data with Devanagari, IAST, and translations
- `Exercise`: Interactive learning exercises with multiple types
- `Lesson`: Structured learning units with objectives
- `ReviewItem`: Spaced repetition items with scheduling data
- `UserProgress`: User statistics and completion tracking

#### Managers
- `DataManager`: Centralized data management and persistence
- `AudioManager`: Audio playback with TTS fallback
- `HapticManager`: Tactile feedback for interactions
- `SpacedRepetitionManager`: Leitner box scheduling algorithm

#### Views
- `OnboardingView`: First-time user setup and preferences
- `MainTabView`: Primary navigation with 5 tabs
- `HomeView`: Daily verse and progress overview
- `LearnView`: Skill tree and lesson navigation
- `ReviewView`: Spaced repetition review system
- `SearchView`: Comprehensive verse search
- `ProfileView`: User statistics and settings

### Data Structure

The app uses a JSON-based seed data system with the following structure:

```json
{
  "chapters": [
    {
      "id": "ch1",
      "index": 1,
      "title_en": "Arjuna's Despair",
      "title_sa": "अर्जुनविषादयोग"
    }
  ],
  "verses": [
    {
      "id": "v2_47",
      "chapter_index": 2,
      "verse_index": 47,
      "devanagari_text": "कर्मण्येवाधिकारस्ते...",
      "iast_text": "karmaṇy-evādhikāras te ...",
      "translation_en": "You have a right to action alone...",
      "keywords": ["karma", "detachment"],
      "audio_url": "bundle://audio/v2_47.mp3",
      "commentary_short": "Focus on your action...",
      "themes": ["duty", "equanimity"]
    }
  ],
  "lessons": [...],
  "exercises": [...]
}
```

### Spaced Repetition System

Implements a simplified Leitner box system:

- **Box 1**: 1 day interval (new items)
- **Box 2**: 3 day interval
- **Box 3**: 7 day interval
- **Box 4**: 14 day interval
- **Box 5**: 30 day interval

Items move up on correct answers, reset to Box 1 on incorrect answers.

### Audio System

- **Bundled Audio**: High-quality MP3 files for key verses
- **TTS Fallback**: AVSpeechSynthesizer for missing audio
- **Playback Controls**: Play, pause, speed adjustment
- **Word-level Audio**: Individual word pronunciation

## User Experience

### Onboarding Flow
1. **Welcome**: App introduction and value proposition
2. **Study Goal**: Choose daily time commitment (5min, 10min, weekend)
3. **Script Display**: Select Devanagari, IAST, or both
4. **Study Time**: Set daily reminder time
5. **Notifications**: Request permission for daily reminders

### Learning Path
1. **Daily Verse**: Start with Verse of the Day
2. **Skill Tree**: Progress through chapters sequentially
3. **Mixed Exercises**: Variety of exercise types per lesson
4. **Review System**: Spaced repetition for retention
5. **Search & Explore**: Find specific verses and themes

### Gamification
- **Streaks**: Daily study consistency tracking
- **XP System**: Points for lesson completion
- **Achievements**: Unlockable badges for milestones
- **Progress Visualization**: Clear completion indicators

## Accessibility

- **Dynamic Type**: Supports all system font sizes
- **VoiceOver**: Full screen reader support
- **High Contrast**: Adapts to system accessibility settings
- **Large Tap Targets**: Minimum 44pt touch targets
- **Semantic Labels**: Proper accessibility traits

## Internationalization

- **English**: Primary language for translations
- **Sanskrit**: Devanagari script support
- **IAST**: Roman transliteration system
- **RTL Ready**: Layout supports right-to-left languages
- **Localizable**: All strings externalized for translation

## Performance

- **Offline First**: Core content works without internet
- **Lazy Loading**: Views load content on demand
- **Efficient Search**: Optimized search algorithms
- **Memory Management**: Proper cleanup and lifecycle management
- **Smooth Animations**: 60fps interactions and transitions

## Testing

Comprehensive test suite covering:

- **Unit Tests**: Data models and business logic
- **Integration Tests**: Manager interactions
- **Performance Tests**: Search and spaced repetition algorithms
- **UI Tests**: Critical user flows
- **Accessibility Tests**: VoiceOver and dynamic type

## Future Enhancements

### Content
- **Additional Translations**: Multiple language support
- **Extended Commentary**: Deeper philosophical insights
- **Audio Expansion**: More verses with native audio
- **Video Content**: Visual explanations and context

### Features
- **Social Learning**: Study groups and sharing
- **Advanced Analytics**: Detailed learning insights
- **Custom Study Plans**: Personalized learning paths
- **Offline Sync**: Cloud backup and sync

### Technical
- **Core Data**: Migration to Core Data for better performance
- **CloudKit**: Sync across devices
- **Widgets**: Home screen verse widgets
- **Apple Watch**: Quick verse access

## Getting Started

1. **Clone the repository**
2. **Open in Xcode 15+**
3. **Build and run on iOS 17+**
4. **Complete onboarding flow**
5. **Start learning!**

## Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **iPhone/iPad compatible**

## License

This project is for educational and personal use. The Bhagavad Gita content is in the public domain.

## Contributing

Contributions are welcome! Please focus on:

- **Bug fixes and improvements**
- **Accessibility enhancements**
- **Performance optimizations**
- **Additional content and translations**

## Acknowledgments

- **Bhagavad Gita**: Sacred text in the public domain
- **Duolingo**: Inspiration for gamified learning approach
- **Manna**: Daily scripture flow concept
- **SwiftUI Community**: For excellent resources and examples

---

*"You have a right to action alone, not to its fruits."* - Bhagavad Gita 2.47
