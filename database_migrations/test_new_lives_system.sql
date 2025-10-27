-- Test the new lives system with JSON array
-- Run this after applying the refactor_lives_system.sql migration

-- =============================================================================
-- TEST DATA SETUP
-- =============================================================================

-- Create a test user with the new structure
INSERT INTO public.user_lives (user_id, current_lives, regeneration_times, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    2,
    '["2025-10-27T23:00:00Z", "2025-10-27T23:10:00Z"]'::jsonb,
    now()
) ON CONFLICT (user_id) DO UPDATE SET
    current_lives = EXCLUDED.current_lives,
    regeneration_times = EXCLUDED.regeneration_times,
    updated_at = EXCLUDED.updated_at;

-- =============================================================================
-- TEST QUERIES
-- =============================================================================

-- Test 1: Check data consistency
SELECT 
    user_id,
    current_lives,
    regeneration_times,
    jsonb_array_length(regeneration_times) as regeneration_count,
    (current_lives + jsonb_array_length(regeneration_times)) as total_should_be_5,
    CASE 
        WHEN (current_lives + jsonb_array_length(regeneration_times)) = 5 THEN '✅ Consistent'
        ELSE '❌ Inconsistent'
    END as status
FROM public.user_lives
WHERE user_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- Test 2: Get next regeneration time
SELECT 
    user_id,
    current_lives,
    regeneration_times,
    (
        SELECT MIN((jsonb_array_elements(regeneration_times)::text)::timestamp with time zone)
        FROM public.user_lives u2 
        WHERE u2.user_id = u1.user_id
    ) as next_regeneration_time
FROM public.user_lives u1
WHERE user_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- Test 3: Add a new regeneration time
UPDATE public.user_lives 
SET regeneration_times = regeneration_times || '["2025-10-27T23:20:00Z"]'::jsonb
WHERE user_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- Test 4: Remove expired times (simulate regeneration)
WITH expired_times AS (
    SELECT jsonb_agg(value ORDER BY value) as new_array
    FROM (
        SELECT value
        FROM jsonb_array_elements(
            (SELECT regeneration_times FROM public.user_lives WHERE user_id = '00000000-0000-0000-0000-000000000001'::uuid)
        ) AS value
        WHERE (value::text)::timestamp with time zone > now()
    ) AS filtered
)
UPDATE public.user_lives 
SET 
    regeneration_times = COALESCE(expired_times.new_array, '[]'::jsonb),
    current_lives = current_lives + (
        SELECT COUNT(*) 
        FROM jsonb_array_elements(regeneration_times) 
        WHERE (value::text)::timestamp with time zone <= now()
    )
FROM expired_times
WHERE user_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- Test 5: Verify final state
SELECT 
    user_id,
    current_lives,
    regeneration_times,
    jsonb_array_length(regeneration_times) as regeneration_count,
    (current_lives + jsonb_array_length(regeneration_times)) as total_should_be_5
FROM public.user_lives
WHERE user_id = '00000000-0000-0000-0000-000000000001'::uuid;

-- =============================================================================
-- CLEANUP
-- =============================================================================

-- Remove test data
DELETE FROM public.user_lives 
WHERE user_id = '00000000-0000-0000-0000-000000000001'::uuid;
