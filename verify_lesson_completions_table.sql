-- Verification script for lesson_completions table
-- Run this in your Supabase SQL editor to check if the table exists and is properly configured

-- 1. Check if the table exists
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_name = 'lesson_completions';

-- 2. Check table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lesson_completions'
ORDER BY ordinal_position;

-- 3. Check if RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'lesson_completions';

-- 4. Check RLS policies
SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'lesson_completions';

-- 5. Check indexes
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'lesson_completions';

-- 6. Test insert (this will fail if RLS is blocking, but that's expected)
-- Replace 'your-user-id' and 'your-lesson-id' with actual UUIDs
/*
INSERT INTO lesson_completions (
    user_id,
    lesson_id,
    score,
    total_questions,
    score_percentage,
    time_elapsed_seconds,
    started_at,
    completed_at
) VALUES (
    'your-user-id'::uuid,
    'your-lesson-id'::uuid,
    5,
    5,
    100.0,
    120,
    NOW(),
    NOW()
);
*/

-- 7. Check if there are any existing records
SELECT COUNT(*) as total_completions FROM lesson_completions;

-- 8. Check if the get_next_attempt_number function exists
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name = 'get_next_attempt_number';
