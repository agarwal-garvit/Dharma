# Lives System Debugging Guide

## Critical Fixes Applied

### 1. Added Database Fetch Logging
Every time data is fetched from the database, you'll now see exactly what was retrieved:

```
📥 DatabaseService: Fetched lives from DB
   user_id: [UUID]
   current_lives: 3
   life_1_regenerates_at: NULL
   life_2_regenerates_at: NULL
   life_3_regenerates_at: NULL
   life_4_regenerates_at: 2024-10-23T16:30:00Z
   life_5_regenerates_at: 2024-10-23T15:30:00Z
```

### 2. Added Database Update Logging
Every time data is sent to the database, you'll see what's being sent:

```
📤 DatabaseService: Sending update to DB...
   current_lives: 3
   life_1_regenerates_at: NULL
   life_2_regenerates_at: NULL
   life_3_regenerates_at: NULL
   life_4_regenerates_at: 2024-10-23T16:30:00Z
   life_5_regenerates_at: 2024-10-23T15:30:00Z
```

### 3. Added Verification After Updates
After every database update, the system now re-fetches to confirm the database state:

```
🔄 LivesManager: Verifying database state...
📥 DatabaseService: Fetched lives from DB
   current_lives: 3
✅ LivesManager: Verification complete - DB shows 3 lives
```

## How to Debug the Mismatch

### Step 1: Check Initial State
When the app starts, look for:

```
🔵 LivesManager: Initializing for user: [UUID]
📥 LivesManager: Fetching lives from database...
📥 DatabaseService: Fetched lives from DB
   current_lives: [NUMBER_FROM_DB]
   [all 5 life slots shown]
📊 LivesManager: Processing lives data - Current lives: [NUMBER]/5
✅ LivesManager: Lives check complete - Current: [LOCAL_STATE]/5
🔵 LivesManager: Initialization complete - Lives: [LOCAL_STATE]/5
```

**What to Check:**
- `current_lives` from DB should match `Local state`
- If they don't match, there's an issue in the processing logic

### Step 2: Check Life Deduction
When you answer incorrectly:

```
💔 LivesManager: Deducting life - Current DB state: [BEFORE]/5
💔 LivesManager: Assigned regeneration to life slot [X]
📤 LivesManager: Updating database after life deduction...
📤 DatabaseService: Sending update to DB...
   current_lives: [AFTER]
   life_[X]_regenerates_at: [TIMESTAMP]
✅ DatabaseService: Update sent successfully
🔄 LivesManager: Verifying database state after deduction...
📥 DatabaseService: Fetched lives from DB
   current_lives: [VERIFIED_VALUE]
✅ LivesManager: Verification complete - DB confirms [VERIFIED_VALUE] lives
✅ LivesManager: Life deduction complete - Local state: [LOCAL_VALUE]/5
```

**What to Check:**
1. `BEFORE` value should match what you expected
2. `AFTER` should be `BEFORE - 1`
3. `VERIFIED_VALUE` should match `AFTER`
4. `LOCAL_VALUE` should match `VERIFIED_VALUE`
5. The assigned slot should have a timestamp (not NULL)

### Step 3: Check Life Regeneration
When a life regenerates:

```
💚 LivesManager: Life slot [X] is ready to regenerate (was due at [TIME])
   ✓ Cleared life_[X]_regenerates_at
💚 LivesManager: Regenerated life - Total lives now: [COUNT]
📤 LivesManager: Updating database with regenerated lives...
📤 DatabaseService: Sending update to DB...
   current_lives: [COUNT]
   life_[X]_regenerates_at: NULL
✅ DatabaseService: Update sent successfully
🔄 LivesManager: Verifying database state...
📥 DatabaseService: Fetched lives from DB
   current_lives: [VERIFIED_COUNT]
   life_[X]_regenerates_at: NULL
✅ LivesManager: Verification complete - DB shows [VERIFIED_COUNT] lives
```

**What to Check:**
1. The cleared slot should show `NULL` in the update
2. `COUNT` should be incremented by 1 for each regenerated life
3. `VERIFIED_COUNT` should match `COUNT`
4. In the verified fetch, the regenerated slot should be `NULL`

## Common Issues and What to Look For

### Issue 1: Local State Doesn't Match DB
**Symptoms:** UI shows different number than database

**Debug in logs:**
1. Find the most recent "📥 DatabaseService: Fetched lives from DB" entry
2. Note the `current_lives` value
3. Find the next "✅ LivesManager: Lives check complete" entry
4. The numbers should match

**If they don't match:** The problem is in the processing logic between fetch and state update

### Issue 2: Timestamps Not Clearing
**Symptoms:** Lives don't regenerate even though time has passed

**Debug in logs:**
1. Look for "💚 LivesManager: Life slot X is ready to regenerate"
2. Look for "✓ Cleared life_X_regenerates_at"
3. Check the "📤 DatabaseService: Sending update to DB..." that follows
4. The cleared slot should show `NULL`
5. Check "📥 DatabaseService: Fetched lives from DB" in verification
6. The slot should still be `NULL`

**If not NULL in verification:** The database isn't accepting NULL values properly

### Issue 3: Double Deduction
**Symptoms:** Losing 2 lives for 1 wrong answer

**Debug in logs:**
1. Look for "💔 LivesManager: Deducting life - Current DB state:"
2. Count how many times this appears in quick succession
3. Each deduction should only happen once and should show different "Current DB state" values
4. The second deduction should be prevented if lives are already 0

**If you see two deductions with the same "Current DB state":** Race condition still exists

### Issue 4: Lives Not Syncing After App Reload
**Symptoms:** Close and reopen app, see different number of lives

**Debug in logs:**
1. Look for "🔵 LivesManager: Initializing for user"
2. The very first "📥 DatabaseService: Fetched lives from DB" shows true DB state
3. Check if "Initialization complete" shows the same number

**If different:** State synchronization is broken

## Manual Database Verification

At any point, you can manually check the database with this SQL query:

```sql
SELECT 
    user_id,
    current_lives,
    life_1_regenerates_at,
    life_2_regenerates_at,
    life_3_regenerates_at,
    life_4_regenerates_at,
    life_5_regenerates_at,
    updated_at,
    NOW() as current_time
FROM user_lives
WHERE user_id = '[YOUR_USER_ID]'::uuid;
```

This will show:
- Current lives count
- Which slots are regenerating (have timestamps)
- Which slots are active (NULL)
- Current server time for comparison

## Expected Behavior

### Normal Flow (5 → 4 → 3 lives):
1. Start: `current_lives: 5`, all slots `NULL`
2. Wrong answer #1:
   - `current_lives: 4`
   - `life_5_regenerates_at: [TIME+1hr]`
   - Other slots: `NULL`
3. Wrong answer #2:
   - `current_lives: 3`
   - `life_5_regenerates_at: [TIME1]`
   - `life_4_regenerates_at: [TIME2]` (TIME2 = TIME1 + 1hr)
   - Other slots: `NULL`

### Regeneration Flow (3 → 4 → 5 lives):
1. After 1 hour (TIME1 passed):
   - `current_lives: 4`
   - `life_5_regenerates_at: NULL` (cleared)
   - `life_4_regenerates_at: [TIME2]` (still future)
2. After 2 hours (TIME2 passed):
   - `current_lives: 5`
   - `life_5_regenerates_at: NULL`
   - `life_4_regenerates_at: NULL` (cleared)

## What the New Verification Does

After EVERY database update operation:
1. Send the update
2. **Immediately fetch back** the data from database
3. Use the fetched data (not the local copy) to update UI
4. This ensures UI always shows exactly what's in the database

This eliminates the possibility of:
- Stale local state
- Failed updates showing incorrect UI
- Discrepancies between DB and UI

## Testing Recommendations

1. **Clear Test**: 
   - Note DB state in Supabase dashboard
   - Perform an action (lose a life)
   - Watch console logs for the full flow
   - Refresh Supabase dashboard
   - Confirm DB matches what logs show

2. **End-to-End Test**:
   - Lose all 5 lives one by one
   - After each loss, check logs show proper verification
   - Close app, reopen
   - Check logs show correct initialization
   - UI should match DB

3. **Regeneration Test**:
   - Lose 1 life
   - Note the timestamp in DB
   - Manually set timestamp to 1 minute ago in Supabase
   - Navigate away and back (triggers check)
   - Life should regenerate
   - Logs should show clearing and verification

## Send Me These Logs

If you still see a mismatch, copy the ENTIRE console output from:
- 🔵 "Initializing for user" 
- Through all the emoji markers
- To ✅ "Initialization complete"

Also include:
- What the UI shows
- What Supabase dashboard shows
- What action you just performed

This will let me see exactly where the mismatch occurs!

