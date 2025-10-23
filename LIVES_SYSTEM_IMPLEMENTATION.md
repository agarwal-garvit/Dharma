# Lives System Implementation Summary

## Overview
Successfully implemented a comprehensive 5-life system where users lose lives on incorrect quiz answers. Lives regenerate sequentially over time (1 hour per life, stacked). Users are blocked from accessing lessons when lives reach 0.

## ✅ Completed Components

### 1. Database Layer

#### SQL Migration (`database_migrations/create_user_lives_table.sql`)
- Created `user_lives` table with the following schema:
  - `user_id` (UUID, FK to auth.users)
  - `current_lives` (INT, default 5, constrained 0-5)
  - `life_1_regenerates_at` through `life_5_regenerates_at` (TIMESTAMP NULL)
  - `updated_at` (TIMESTAMP)
- Row Level Security (RLS) policies for user data protection
- Automatic trigger to initialize lives for new users
- NULL timestamps indicate active lives, non-NULL indicates regeneration time

#### Database Model (`DatabaseModels.swift`)
- Added `DBUserLives` struct with Codable conformance
- Proper CodingKeys mapping for snake_case database columns

#### Database Service (`DatabaseService.swift`)
- `fetchUserLives(userId:)` - Retrieves user's lives from database
- `initializeUserLives(userId:)` - Creates initial lives record (5 lives)
- `updateUserLives(lives:)` - Updates lives and regeneration timestamps

### 2. Business Logic Layer

#### Lives Manager (`Managers/LivesManager.swift`)
- Singleton pattern with `@Published` properties for reactive UI updates
- **State Management:**
  - `currentLives: Int` - Current number of lives (0-5)
  - `nextLifeRegenerationTime: Date?` - When next life regenerates
  - `isLoading: Bool` - Loading state indicator

- **Core Functions:**
  - `initializeForUser(userId:)` - Initialize lives for a specific user
  - `checkAndRegenerateLives()` - Checks DB, regenerates expired lives
  - `deductLife()` - Removes a life, sets regeneration timestamp with stacking
  - `getTimeUntilNextLife()` - Returns seconds until next regeneration
  - `getFormattedTimeUntilNextLife()` - Returns HH:MM:SS formatted string

- **Features:**
  - Background timer that checks every second for regeneration
  - Automatic stacking of regeneration times (queued regeneration)
  - Haptic feedback on life loss
  - Comprehensive logging for debugging

### 3. UI Components

#### Lives Display View (`Views/Components/LivesDisplayView.swift`)
- Compact navigation bar component
- Shows heart icon with number overlay (red for lives > 0, gray for 0)
- Displays countdown timer when lives < 5
- Tappable to open lives modal
- Reactive to LivesManager state changes

#### Lives Modal View (`Views/Components/LivesModalView.swift`)
- Full-screen modal with comprehensive information
- **Features:**
  - 5 hearts display (red for active, gray for lost)
  - Current lives count (X / 5)
  - Countdown timer (HH:MM:SS format)
  - "Unlimited lives coming soon!" promotional message
  - Reload app reminder for sync issues
  - Dynamic dismiss button (shows "OK" when 0 lives, "Continue" otherwise)

### 4. Integration Points

#### LearnView (`Views/Learn/LearnView.swift`)
- ✅ Profile button moved to `.navigationBarLeading`
- ✅ Lives display added to `.navigationBarTrailing`
- ✅ Lives check on `.onAppear()` to regenerate expired lives
- ✅ Lesson access gating - checks lives before allowing lesson start
- ✅ Shows lives modal when attempting to access lesson with 0 lives

#### DailyView (`Views/Daily/DailyView.swift`)
- ✅ Profile button added to `.navigationBarLeading`
- ✅ Lives display added to `.navigationBarTrailing`
- ✅ Lives check on `.onAppear()` to regenerate expired lives

#### QuizView (`Views/Learn/QuizView.swift`)
- ✅ Exit button moved to `.navigationBarLeading`
- ✅ Lives display added to `.navigationBarTrailing`
- ✅ Lives check on `.onAppear()` when quiz starts
- ✅ Life deduction on incorrect answer in `selectAnswer()`
- ✅ Shows lives modal and exits quiz when lives hit 0
- ✅ Modal auto-dismisses and exits quiz when lives are depleted

#### HomeView (`Views/Home/HomeView.swift`)
- ✅ Lives display added to `.navigationBarTrailing`
- ✅ Lives check on `.onAppear()` to regenerate expired lives

#### MainTabView (`Views/MainTabView.swift`)
- ✅ Lives manager initialization on `.onAppear()` with current user ID
- ✅ Entry point for app-wide lives system initialization

## Life Regeneration Logic

### Deduction and Stacking
When a life is lost:
1. `currentLives` is decremented
2. System finds next available life slot (5 → 4 → 3 → 2 → 1)
3. Calculates regeneration time:
   - If no queue: `now + 1 hour`
   - If queue exists: `latest_regeneration_time + 1 hour` (stacking)
4. Sets timestamp for that life slot
5. Updates database

### Regeneration Check
Runs automatically every second via timer:
1. Fetches current lives from database
2. Checks each life slot's timestamp
3. For timestamps that have passed:
   - Increments `currentLives`
   - Clears that slot's timestamp (sets to NULL)
4. Updates database with changes
5. Updates UI via `@Published` properties

### Example Flow
- User has 5 lives at 1:00 PM
- Loses life at 1:00 PM → 4 lives, life_5 regenerates at 2:00 PM
- Loses life at 1:10 PM → 3 lives, life_4 regenerates at 3:00 PM (stacked)
- At 2:00 PM → Auto-regenerate to 4 lives
- At 3:00 PM → Auto-regenerate to 5 lives

## User Experience Flow

### Normal Flow
1. User opens app → Lives initialize
2. User navigates to Learn tab → Lives check and regenerate
3. User starts lesson → Lives check passed, lesson opens
4. User answers quiz incorrectly → Life deducted, continues
5. Lives regenerate automatically after 1 hour each

### Zero Lives Flow
1. User has 0 lives
2. Attempts to start lesson → Lives modal appears
3. Modal shows:
   - 5 gray hearts (🩶🩶🩶🩶🩶)
   - "0 / 5 Lives"
   - Countdown timer to next life
   - Helpful messages
4. User must wait or can view modal from nav bar

### During Quiz Zero Lives Flow
1. User is in quiz with 1 life
2. Answers incorrectly → Life deducted to 0
3. Lives modal appears immediately
4. User dismisses modal → Exits quiz automatically
5. Returns to Learn view

## Testing Checklist

- ✅ SQL migration created with proper schema
- ✅ Database models and services implemented
- ✅ Lives manager with full regeneration logic
- ✅ UI components (display + modal) created
- ✅ All navigation toolbars updated
- ✅ Life deduction on incorrect answers
- ✅ Lives check before lesson access
- ✅ Lives modal on 0 lives (lesson start)
- ✅ Lives modal on 0 lives (during quiz)
- ✅ Auto-exit quiz when lives depleted
- ✅ Background timer for regeneration
- ✅ Stacked regeneration timing
- ✅ Haptic feedback on life loss
- ✅ Profile buttons moved to left side
- ✅ Lives display visible on all major views

## Files Created
1. `/database_migrations/create_user_lives_table.sql`
2. `/Dharma/Managers/LivesManager.swift`
3. `/Dharma/Views/Components/LivesDisplayView.swift`
4. `/Dharma/Views/Components/LivesModalView.swift`

## Files Modified
1. `/Dharma/Models/DatabaseModels.swift` - Added `DBUserLives`
2. `/Dharma/Managers/DatabaseService.swift` - Added lives operations
3. `/Dharma/Views/Learn/LearnView.swift` - Toolbar, gating, lives checks
4. `/Dharma/Views/Learn/QuizView.swift` - Toolbar, life deduction, modal
5. `/Dharma/Views/Daily/DailyView.swift` - Toolbar, lives checks
6. `/Dharma/Views/Home/HomeView.swift` - Toolbar, lives checks
7. `/Dharma/Views/MainTabView.swift` - Lives initialization

## Next Steps for Deployment

### Database Setup
1. Run the SQL migration on your Supabase instance:
   ```sql
   -- Execute contents of database_migrations/create_user_lives_table.sql
   ```
2. Verify RLS policies are active
3. Test with a new user signup to ensure automatic initialization

### Testing Recommendations
1. **Create Test User**: Sign up with a new account
2. **Verify Initial State**: Check that user starts with 5 lives
3. **Test Life Loss**: Answer quiz questions incorrectly, verify deduction
4. **Test Lesson Blocking**: Deplete all lives, verify lesson access blocked
5. **Test Regeneration**: 
   - Option A: Manually update database timestamps to past times
   - Option B: Wait 1 hour and verify regeneration
6. **Test Stacking**: Lose multiple lives quickly, verify regeneration queue
7. **Test UI**: Verify lives display updates in real-time across all views

### Monitoring
- Watch console logs for lives operations (marked with 💚, 💔, ✅, ❌)
- Monitor database for proper timestamp updates
- Check RLS policies don't block legitimate operations

## Known Considerations

1. **Time Zone**: All times use ISO8601 with time zone awareness
2. **Offline Mode**: Lives checks require network connection
3. **Multiple Devices**: Lives sync across devices via database
4. **Background App**: Timer continues when app is in foreground only
5. **Database Lag**: Small delay possible between life loss and UI update

## Future Enhancements (Noted in Modal)
- "Unlimited lives coming soon!" - Premium/subscription feature
- Lives marketplace or earning system
- Daily life bonuses
- Streak-based life rewards

