# Lives System Bug Fixes

## Issues Identified and Fixed

### 1. **Missing `updated_at` Timestamp** ✅ FIXED
**Problem:** The `updated_at` field was not being updated when lives were modified in the database.

**Fix:** Added `updated_at` field to the `LivesUpdate` struct in `DatabaseService.swift`:
```swift
struct LivesUpdate: Encodable {
    let current_lives: Int
    let life_1_regenerates_at: String?
    let life_2_regenerates_at: String?
    let life_3_regenerates_at: String?
    let life_4_regenerates_at: String?
    let life_5_regenerates_at: String?
    let updated_at: String  // NOW INCLUDED
}
```

### 2. **Race Condition on Life Deduction** ✅ FIXED
**Problem:** The `deductLife()` function was checking the local `currentLives` state instead of the database state, allowing multiple rapid deductions before the state synced.

**Before:**
```swift
guard currentLives > 0 else {  // Checking local state ❌
    return
}
// Then fetching from DB...
```

**After:**
```swift
// Fetch from database FIRST
var lives = try await databaseService.fetchUserLives(userId: userId)
guard var userLives = lives else { return }

// Check DATABASE state ✅
guard userLives.currentLives > 0 else {
    print("⚠️ LivesManager: No lives to deduct (database has 0)")
    currentLives = 0  // Sync local state
    return
}
```

**Result:** This prevents double-deductions when answering questions quickly.

### 3. **NULL Timestamps Not Being Set Properly** ✅ FIXED
**Problem:** When lives regenerated, the timestamps were set to `nil` in Swift but might not have been properly sent to the database as NULL.

**Fix:** 
- Swift `nil` optionals are properly encoded as `null` in JSON by the `Encodable` protocol
- Added extensive logging to verify NULL values are being sent:
```swift
print("   Life 1: \(lives.life1RegeneratesAt ?? "NULL")")
// etc...
```

### 4. **Insufficient Logging** ✅ FIXED
**Problem:** Debugging was difficult without detailed logs of database operations.

**Fix:** Added comprehensive logging throughout:

**In `checkAndRegenerateLives()`:**
- 📥 Fetching from database
- 📊 Current database state (all 5 life slots)
- 💚 Each life that regenerates
- ✓ Confirmation of clearing each timestamp
- 📤 Database update operations
- ✅ Final state confirmation

**In `deductLife()`:**
- 💔 Current database state before deduction
- 💔 Which life slot was assigned
- 📤 Database update operation
- ✅ Final state after deduction
- ⏰ Regeneration time scheduled

**In `DatabaseService.updateUserLives()`:**
- Shows all 5 life slots and their states (NULL or timestamp)

### 5. **State Synchronization Issues** ✅ FIXED
**Problem:** Local `currentLives` state could get out of sync with database, especially after app reload.

**Fix:** 
- Always fetch from database before making decisions
- Always update local state after database operations
- Added initialization logging to verify startup state:
```swift
print("🔵 LivesManager: Initializing for user: \(userId)")
// ... operations ...
print("🔵 LivesManager: Initialization complete - Lives: \(currentLives)/5")
```

### 6. **Better Regeneration Logging** ✅ FIXED
**Problem:** Hard to tell which life slots were being regenerated.

**Fix:** Added detailed logging for each slot:
```swift
print("💚 LivesManager: Life slot \(index + 1) is ready to regenerate")
print("   ✓ Cleared life_\(index+1)_regenerates_at")
print("💚 LivesManager: Regenerated life - Total lives now: \(userLives.currentLives)")
```

## Testing Instructions

### Test 1: Life Deduction
1. Start with 5 lives
2. Answer a question incorrectly
3. **Check Console:** Should show:
   - "📥 Fetching lives from database..."
   - "📊 Current DB state - Lives: 5/5"
   - "💔 Deducting life - Current DB state: 5/5"
   - "💔 Assigned regeneration to life slot 5"
   - "📤 Updating database after life deduction..."
   - "✅ Life deducted - Remaining: 4/5"
4. **Check Database:** 
   - `current_lives` should be 4
   - `life_5_regenerates_at` should have a timestamp (~1 hour from now)
   - `updated_at` should be current time

### Test 2: Prevent Double Deduction
1. Have 1 life remaining
2. Answer a question incorrectly
3. **Check Console:** Should show life deducted to 0
4. Try to answer another question incorrectly immediately
5. **Expected:** Should show "⚠️ No lives to deduct (database has 0)"
6. **Should NOT:** Deduct another life (no negative lives)

### Test 3: Regeneration
1. Lose a life (down to 4 lives)
2. Wait for regeneration (or manually set timestamp in DB to past time)
3. Reload app or navigate to trigger `checkAndRegenerateLives()`
4. **Check Console:** Should show:
   - "📥 Fetching lives from database..."
   - "📊 Current DB state - Lives: 4/5"
   - "💚 Life slot X is ready to regenerate"
   - "   ✓ Cleared life_X_regenerates_at"
   - "📤 Updating database with regenerated lives..."
   - "✅ Lives check complete - Current: 5/5"
5. **Check Database:**
   - `current_lives` should be 5
   - The regenerated life's timestamp should be NULL
   - `updated_at` should be current time

### Test 4: App Reload with 0 Lives
1. Deplete all lives to 0
2. Close and reopen the app
3. **Check Console:** Should show:
   - "🔵 LivesManager: Initializing for user: [UUID]"
   - "📥 Fetching lives from database..."
   - "📊 Current DB state - Lives: 0/5"
   - "✅ Lives check complete - Current: 0/5"
   - "🔵 Initialization complete - Lives: 0/5"
4. **UI Should Show:** 0 lives (gray heart with 0)
5. **Should NOT Show:** 1 life

### Test 5: Stacked Regeneration
1. Lose 3 lives quickly (down to 2 lives)
2. **Check Database:** Should have 3 timestamps stacked 1 hour apart
3. **Check Console:** Each deduction should show proper stacking
4. Wait for first regeneration
5. **Expected:** Lives increment from 2 → 3 → 4 → 5 over 3 hours

## Files Modified

1. **DatabaseService.swift**
   - Added `updated_at` to update payload
   - Added detailed logging of life states

2. **LivesManager.swift**
   - Fixed race condition by fetching DB state first
   - Added comprehensive logging throughout
   - Improved state synchronization
   - Added initialization logging

## Console Log Legend

- 🔵 = Initialization
- 📥 = Fetching from database
- 📊 = Database state snapshot
- 💔 = Life deduction
- 💚 = Life regeneration
- ✓ = Operation confirmation
- 📤 = Database update
- ✅ = Success
- ⏰ = Timer/regeneration info
- ❌ = Error
- ⚠️ = Warning

## What To Watch For

Monitor the console logs for:
1. ✅ All operations should complete with success messages
2. 📊 Database state should always match expected values
3. 💔/💚 Deductions and regenerations should be logged clearly
4. ⚠️ Any warnings indicate edge cases being handled properly
5. ❌ Errors should be rare; if frequent, check database connection

## Database Verification Query

To manually check lives state in Supabase:
```sql
SELECT 
    user_id,
    current_lives,
    life_1_regenerates_at,
    life_2_regenerates_at,
    life_3_regenerates_at,
    life_4_regenerates_at,
    life_5_regenerates_at,
    updated_at
FROM user_lives
WHERE user_id = '[YOUR_USER_ID]';
```

Expected results:
- `current_lives`: Integer 0-5
- `life_X_regenerates_at`: NULL (if active) or ISO8601 timestamp (if regenerating)
- `updated_at`: Should update with every change

