# Daily Feature Database Integration

This document outlines the complete setup for the Daily feature with database integration, replacing the hardcoded data with a proper database-driven approach.

## Overview

The Daily feature now uses a PostgreSQL database to store and retrieve daily verses, providing better scalability, data management, and consistency across users.

## Files Created/Modified

### 1. Database Schema
- **`database_migrations/daily_verses_setup.sql`** - Creates the daily_verses table and helper functions
- **`database_migrations/seed_daily_verses.sql`** - Sample data with 10 daily verses
- **`database_migrations/complete_daily_setup.sql`** - Complete setup script combining table creation and data

### 2. Swift Code Changes
- **`Dharma/Models/DatabaseModels.swift`** - Added `DBDailyVerse` model
- **`Dharma/Managers/DatabaseService.swift`** - Added daily verse database operations
- **`Dharma/Views/Daily/DailyView.swift`** - Updated to use database instead of hardcoded data

## Database Schema

### Table: `daily_verses`
```sql
CREATE TABLE daily_verses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL UNIQUE,
    verse_id VARCHAR(255) NOT NULL,
    chapter_index INTEGER NOT NULL,
    verse_index INTEGER NOT NULL,
    devanagari_text TEXT NOT NULL,
    iast_text TEXT NOT NULL,
    translation_en TEXT NOT NULL,
    keywords TEXT[] DEFAULT '{}',
    themes TEXT[] DEFAULT '{}',
    commentary_short TEXT,
    audio_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Helper Functions
- `get_daily_verse_by_date(p_date DATE)` - Get verse for specific date
- `get_daily_verse_by_day_of_year(p_day_of_year INTEGER)` - Get verse by day of year (cycling)
- `get_next_daily_verse()` - Get next available verse

## Sample Data

The setup includes 10 sample daily verses starting from October 27, 2025:

1. **Oct 27, 2025** - Bhagavad Gita 1.28 (Arjuna's moral crisis)
2. **Oct 28, 2025** - Bhagavad Gita 2.47 (Karma Yoga - duty without attachment)
3. **Oct 29, 2025** - Bhagavad Gita 2.48 (Equanimity in action)
4. **Oct 30, 2025** - Bhagavad Gita 4.7 (Divine manifestation)
5. **Oct 31, 2025** - Bhagavad Gita 2.62 (Chain of desire and anger)
6. **Nov 1, 2025** - Bhagavad Gita 2.63 (Consequences of anger)
7. **Nov 2, 2025** - Bhagavad Gita 2.64 (Solution through detachment)
8. **Nov 3, 2025** - Bhagavad Gita 2.70 (Ocean metaphor for peace)
9. **Nov 4, 2025** - Bhagavad Gita 2.71 (Characteristics of peaceful person)
10. **Nov 5, 2025** - Bhagavad Gita 2.72 (Spiritual way of life)

## Database Service Methods

### New Methods in `DatabaseService.swift`:
- `fetchDailyVerse(for date: Date)` - Get verse for specific date
- `fetchDailyVerseByDayOfYear(dayOfYear: Int)` - Get verse by day of year
- `fetchNextDailyVerse()` - Get next available verse
- `fetchAllDailyVerses()` - Get all daily verses
- `createDailyVerse(...)` - Create new daily verse

## App Integration

### Updated `DailyView.swift`:
The `loadDailyVerse()` method now:
1. First tries to fetch verse for today's date
2. Falls back to day-of-year cycling if no verse for today
3. Falls back to next available verse
4. Finally falls back to sample verse if database is unavailable

### Data Model Conversion:
The `DBDailyVerse` model includes a `toVerse()` method that converts database records to the app's `Verse` model for seamless integration.

## Setup Instructions

1. **Run the complete setup script:**
   ```sql
   -- Execute this in your Supabase SQL editor
   \i database_migrations/complete_daily_setup.sql
   ```

2. **Verify the setup:**
   - Check that the `daily_verses` table exists
   - Verify 10 sample records are inserted
   - Test the helper functions

3. **Test the app:**
   - The Daily view should now load verses from the database
   - Each day should show a different verse
   - Fallback to sample data if database is unavailable

## Benefits

1. **Scalability** - Easy to add more daily verses
2. **Consistency** - All users see the same verse on the same day
3. **Flexibility** - Can schedule specific verses for specific dates
4. **Maintainability** - Centralized data management
5. **Performance** - Indexed queries for fast lookups
6. **Reliability** - Fallback mechanisms ensure the feature always works

## Future Enhancements

1. **Admin Interface** - Add ability to manage daily verses
2. **Scheduling** - Advanced scheduling for special dates
3. **Personalization** - User-specific daily verses based on preferences
4. **Analytics** - Track which verses are most popular
5. **Audio Integration** - Add audio URLs for verse recitation
6. **Multilingual Support** - Support for multiple languages

## Error Handling

The implementation includes comprehensive error handling:
- Database connection failures fall back to sample data
- Missing verses fall back to cycling through available verses
- All errors are logged for debugging
- User experience remains smooth even with database issues

This setup provides a robust foundation for the Daily feature while maintaining backward compatibility and ensuring a smooth user experience.
