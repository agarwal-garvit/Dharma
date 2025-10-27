-- Refactor Lives System to use JSON array instead of separate timestamp fields
-- This migration changes the user_lives table to use a single regeneration_times field

-- =============================================================================
-- BACKUP EXISTING DATA (optional - for safety)
-- =============================================================================

-- Create a backup table with the old structure
CREATE TABLE IF NOT EXISTS user_lives_backup AS 
SELECT * FROM public.user_lives;

-- =============================================================================
-- ADD NEW COLUMN
-- =============================================================================

-- Add the new regeneration_times column as JSONB array
ALTER TABLE public.user_lives 
ADD COLUMN regeneration_times jsonb DEFAULT '[]'::jsonb;

-- =============================================================================
-- RESET ALL DATA TO CLEAN STATE
-- =============================================================================

-- Reset all users to 5 lives with no regeneration times
UPDATE public.user_lives 
SET 
    current_lives = 5,
    regeneration_times = '[]'::jsonb,
    updated_at = now();

-- =============================================================================
-- VERIFY RESET
-- =============================================================================

-- Check that all users now have 5 lives
SELECT 
    user_id,
    current_lives,
    regeneration_times,
    jsonb_array_length(regeneration_times) as regeneration_count,
    (current_lives + jsonb_array_length(regeneration_times)) as total
FROM public.user_lives
ORDER BY user_id;

-- =============================================================================
-- DROP OLD COLUMNS (after verification)
-- =============================================================================

-- Drop the old individual timestamp columns
ALTER TABLE public.user_lives 
DROP COLUMN IF EXISTS life_1_regenerates_at,
DROP COLUMN IF EXISTS life_2_regenerates_at,
DROP COLUMN IF EXISTS life_3_regenerates_at,
DROP COLUMN IF EXISTS life_4_regenerates_at,
DROP COLUMN IF EXISTS life_5_regenerates_at;

-- =============================================================================
-- DATA IS ALREADY CLEAN (all users reset to 5 lives)
-- =============================================================================

-- No cleanup needed since we reset all data to a clean state

-- =============================================================================
-- ADD CONSTRAINTS AND INDEXES
-- =============================================================================

-- Add constraint to ensure regeneration_times is always an array
ALTER TABLE public.user_lives 
ADD CONSTRAINT check_regeneration_times_is_array 
CHECK (jsonb_typeof(regeneration_times) = 'array');

-- Add constraint to ensure current_lives + regeneration_count = 5
ALTER TABLE public.user_lives 
ADD CONSTRAINT check_lives_consistency 
CHECK (current_lives + jsonb_array_length(regeneration_times) = 5);

-- Add index for efficient querying of regeneration times
CREATE INDEX idx_user_lives_regeneration_times 
ON public.user_lives USING GIN (regeneration_times);

-- =============================================================================
-- UPDATE RLS POLICIES (if needed)
-- =============================================================================

-- The existing RLS policies should still work since we're not changing the table structure significantly
-- But let's verify they exist
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'user_lives';

-- =============================================================================
-- CREATE HELPER FUNCTIONS
-- =============================================================================

-- Function to get the next regeneration time
CREATE OR REPLACE FUNCTION get_next_regeneration_time(user_uuid UUID)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
DECLARE
    next_time TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT MIN(timestamp_value)
    INTO next_time
    FROM (
        SELECT (jsonb_array_elements(regeneration_times)::text)::timestamp with time zone AS timestamp_value
        FROM public.user_lives 
        WHERE user_id = user_uuid
        AND jsonb_array_length(regeneration_times) > 0
    ) AS timestamps;
    
    RETURN next_time;
END;
$$ LANGUAGE plpgsql;

-- Function to add a regeneration time
CREATE OR REPLACE FUNCTION add_regeneration_time(
    user_uuid UUID, 
    regeneration_timestamp TIMESTAMP WITH TIME ZONE
)
RETURNS VOID AS $$
BEGIN
    UPDATE public.user_lives 
    SET regeneration_times = regeneration_times || to_jsonb(regeneration_timestamp)
    WHERE user_id = user_uuid;
END;
$$ LANGUAGE plpgsql;

-- Function to remove the earliest regeneration time
CREATE OR REPLACE FUNCTION remove_earliest_regeneration_time(user_uuid UUID)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
DECLARE
    earliest_time TIMESTAMP WITH TIME ZONE;
    new_array jsonb;
BEGIN
    -- Get the earliest time
    SELECT MIN(timestamp_value)
    INTO earliest_time
    FROM (
        SELECT (jsonb_array_elements(regeneration_times)::text)::timestamp with time zone AS timestamp_value
        FROM public.user_lives 
        WHERE user_id = user_uuid
    ) AS timestamps;
    
    -- Remove the earliest time from the array
    SELECT jsonb_agg(value ORDER BY value)
    INTO new_array
    FROM (
        SELECT value
        FROM jsonb_array_elements(
            (SELECT regeneration_times FROM public.user_lives WHERE user_id = user_uuid)
        ) AS value
        WHERE (value::text)::timestamp with time zone != earliest_time
    ) AS filtered;
    
    -- Update the array
    UPDATE public.user_lives 
    SET regeneration_times = COALESCE(new_array, '[]'::jsonb)
    WHERE user_id = user_uuid;
    
    RETURN earliest_time;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Test the helper functions
SELECT 
    user_id,
    current_lives,
    regeneration_times,
    get_next_regeneration_time(user_id) as next_regeneration
FROM public.user_lives
LIMIT 5;

-- Check data consistency
SELECT 
    user_id,
    current_lives,
    jsonb_array_length(regeneration_times) as regeneration_count,
    (current_lives + jsonb_array_length(regeneration_times)) as total_should_be_5
FROM public.user_lives
WHERE (current_lives + jsonb_array_length(regeneration_times)) != 5;
