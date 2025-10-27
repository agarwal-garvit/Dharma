# New Lives System - JSON Array Approach

## Overview

The lives system has been refactored to use a single JSON array field (`regeneration_times`) instead of 5 separate timestamp fields. This approach is much cleaner, more flexible, and eliminates the complexity of slot management.

## Database Schema

### Before (Old System)
```sql
CREATE TABLE public.user_lives (
    user_id uuid PRIMARY KEY,
    current_lives integer DEFAULT 5,
    life_1_regenerates_at timestamp with time zone,
    life_2_regenerates_at timestamp with time zone,
    life_3_regenerates_at timestamp with time zone,
    life_4_regenerates_at timestamp with time zone,
    life_5_regenerates_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now()
);
```

### After (New System)
```sql
CREATE TABLE public.user_lives (
    user_id uuid PRIMARY KEY,
    current_lives integer DEFAULT 5,
    regeneration_times jsonb DEFAULT '[]'::jsonb,
    updated_at timestamp with time zone DEFAULT now(),
    
    -- Constraints
    CONSTRAINT check_regeneration_times_is_array 
        CHECK (jsonb_typeof(regeneration_times) = 'array'),
    CONSTRAINT check_lives_consistency 
        CHECK (current_lives + jsonb_array_length(regeneration_times) = 5)
);
```

## How It Works

### Data Consistency
- **Total lives = current_lives + regeneration_times.count**
- **Always equals 5** (enforced by database constraint)
- **Empty regeneration_times array = all 5 lives active**

### Examples

**5 Lives Active:**
```json
{
  "current_lives": 5,
  "regeneration_times": []
}
```

**3 Lives Active, 2 Regenerating:**
```json
{
  "current_lives": 3,
  "regeneration_times": [
    "2025-10-27T23:00:00Z",
    "2025-10-27T23:10:00Z"
  ]
}
```

**0 Lives Active, 5 Regenerating:**
```json
{
  "current_lives": 0,
  "regeneration_times": [
    "2025-10-27T23:00:00Z",
    "2025-10-27T23:10:00Z",
    "2025-10-27T23:20:00Z",
    "2025-10-27T23:30:00Z",
    "2025-10-27T23:40:00Z"
  ]
}
```

## Code Changes

### Database Model
```swift
struct DBUserLives: Codable {
    let userId: UUID
    var currentLives: Int
    var regenerationTimes: [String] // Array of ISO8601 timestamps
    let updatedAt: String?
    
    // Computed properties for easy access
    var nextRegenerationTime: Date?
    var futureRegenerationTimes: [Date]
    var livesBeingRegenerated: Int
    var isConsistent: Bool
}
```

### Lives Manager Logic
```swift
// Deduct life
userLives.currentLives -= 1
let regenerationTime = Date().addingTimeInterval(600) // 10 minutes
userLives.regenerationTimes.append(ISO8601DateFormatter().string(from: regenerationTime))
userLives.regenerationTimes.sort() // Keep chronological order

// Regenerate lives
let now = Date()
let expiredTimes = userLives.regenerationTimes.filter { timeString in
    guard let time = ISO8601DateFormatter().date(from: timeString) else { return false }
    return time <= now
}

userLives.currentLives += expiredTimes.count
userLives.regenerationTimes = userLives.regenerationTimes.filter { timeString in
    guard let time = ISO8601DateFormatter().date(from: timeString) else { return true }
    return time > now
}
```

## Benefits

### 1. **Simplicity**
- No more complex slot management
- Single field to manage all regeneration times
- Order doesn't matter - just add/remove from array

### 2. **Flexibility**
- Easy to add/remove regeneration times
- Can handle any number of lives (not just 5)
- Simple to extend in the future

### 3. **Data Integrity**
- Database constraints ensure consistency
- No more slot assignment bugs
- Clear relationship between current lives and regeneration queue

### 4. **Performance**
- JSONB indexing for fast queries
- Simple array operations
- No complex joins needed

### 5. **Maintainability**
- Much cleaner code
- Easier to debug
- Less prone to errors

## Migration Steps

1. **Run the migration**: `refactor_lives_system.sql`
2. **Update the code**: Replace old LivesManager with new one
3. **Test**: Use `test_new_lives_system.sql` to verify
4. **Deploy**: The new system is backward compatible

## Testing

The new system includes comprehensive tests:
- Data consistency checks
- Regeneration time calculations
- Array operations
- Database constraints

## Backward Compatibility

The migration preserves all existing data and maintains the same API, so no changes are needed in the UI or other parts of the app.
