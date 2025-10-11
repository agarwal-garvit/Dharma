-- Daily Usage and Streak Tracking Setup for Dharma (No RLS Version)
-- Run this in your Supabase SQL editor
-- This script updates the existing daily_usage table and functions

-- First, disable RLS if it was previously enabled
ALTER TABLE daily_usage DISABLE ROW LEVEL SECURITY;

-- Drop existing RLS policies if they exist
DROP POLICY IF EXISTS "Users can view their own daily usage" ON daily_usage;
DROP POLICY IF EXISTS "Users can insert their own daily usage" ON daily_usage;
DROP POLICY IF EXISTS "Users can update their own daily usage" ON daily_usage;

-- Update the daily_usage table to match the expected schema
-- Add missing columns if they don't exist
DO $$ 
BEGIN
    -- Add last_active_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'daily_usage' AND column_name = 'last_active_at') THEN
        ALTER TABLE daily_usage ADD COLUMN last_active_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
    
    -- Rename usage_date to date if needed (to match existing schema)
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'daily_usage' AND column_name = 'usage_date') THEN
        ALTER TABLE daily_usage RENAME COLUMN usage_date TO date;
    END IF;
END $$;

-- Ensure the table has the correct structure
CREATE TABLE IF NOT EXISTS daily_usage (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    session_count INTEGER DEFAULT 1,
    total_time_seconds INTEGER DEFAULT 0,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one record per user per day
    UNIQUE(user_id, date)
);

-- Create indexes for better performance (drop and recreate to ensure they exist)
DROP INDEX IF EXISTS idx_daily_usage_user_id;
DROP INDEX IF EXISTS idx_daily_usage_date;
DROP INDEX IF EXISTS idx_daily_usage_user_date;

CREATE INDEX idx_daily_usage_user_id ON daily_usage(user_id);
CREATE INDEX idx_daily_usage_date ON daily_usage(date);
CREATE INDEX idx_daily_usage_user_date ON daily_usage(user_id, date);

-- Drop existing triggers and functions to avoid conflicts
DROP TRIGGER IF EXISTS trigger_update_daily_usage_updated_at ON daily_usage;
DROP TRIGGER IF EXISTS trigger_daily_usage_update_streaks ON daily_usage;
DROP TRIGGER IF EXISTS update_daily_usage_updated_at ON daily_usage;

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_daily_usage_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on daily_usage
CREATE TRIGGER trigger_update_daily_usage_updated_at
    BEFORE UPDATE ON daily_usage
    FOR EACH ROW
    EXECUTE FUNCTION update_daily_usage_updated_at();

-- Create function to record daily usage (upsert) - updated to use 'date' column
CREATE OR REPLACE FUNCTION record_daily_usage(
    p_user_id UUID,
    p_usage_date DATE DEFAULT CURRENT_DATE,
    p_session_time_seconds INTEGER DEFAULT 0
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO daily_usage (user_id, date, session_count, total_time_seconds, last_active_at)
    VALUES (p_user_id, p_usage_date, 1, p_session_time_seconds, NOW())
    ON CONFLICT (user_id, date)
    DO UPDATE SET
        session_count = daily_usage.session_count + 1,
        total_time_seconds = daily_usage.total_time_seconds + p_session_time_seconds,
        last_active_at = NOW(),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Create function to calculate user streaks (returns both current and longest)
CREATE OR REPLACE FUNCTION calculate_user_streaks(p_user_id UUID)
RETURNS TABLE(current_streak INTEGER, longest_streak INTEGER) AS $$
DECLARE
    usage_dates DATE[];
    current_streak_count INTEGER := 0;
    longest_streak_count INTEGER := 0;
    temp_streak INTEGER := 0;
    i INTEGER;
    today_date DATE := CURRENT_DATE;
    was_active_today BOOLEAN := FALSE;
    check_date DATE;
BEGIN
    -- Get all usage dates for the user, sorted by date
    SELECT ARRAY_AGG(date ORDER BY date) INTO usage_dates
    FROM daily_usage
    WHERE user_id = p_user_id;
    
    -- If no usage data, return zeros
    IF usage_dates IS NULL OR array_length(usage_dates, 1) = 0 THEN
        RETURN QUERY SELECT 0, 0;
        RETURN;
    END IF;
    
    -- Check if user was active today
    was_active_today := today_date = ANY(usage_dates);
    
    -- Calculate current streak
    check_date := CASE WHEN was_active_today THEN today_date ELSE today_date - INTERVAL '1 day' END;
    
    WHILE check_date = ANY(usage_dates) LOOP
        current_streak_count := current_streak_count + 1;
        check_date := check_date - INTERVAL '1 day';
    END LOOP;
    
    -- Calculate longest streak
    FOR i IN 1..array_length(usage_dates, 1) LOOP
        IF i = 1 OR usage_dates[i] = usage_dates[i-1] + INTERVAL '1 day' THEN
            temp_streak := temp_streak + 1;
        ELSE
            longest_streak_count := GREATEST(longest_streak_count, temp_streak);
            temp_streak := 1;
        END IF;
    END LOOP;
    
    longest_streak_count := GREATEST(longest_streak_count, temp_streak);
    
    RETURN QUERY SELECT current_streak_count, longest_streak_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to calculate current streak only (for backward compatibility)
CREATE OR REPLACE FUNCTION calculate_user_streak(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    streak_data RECORD;
BEGIN
    SELECT * INTO streak_data FROM calculate_user_streaks(p_user_id);
    RETURN streak_data.current_streak;
END;
$$ LANGUAGE plpgsql;

-- Function to increment user XP
CREATE OR REPLACE FUNCTION increment_user_xp(p_user_id UUID, p_xp_amount INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Insert or update user stats
    INSERT INTO user_stats (user_id, xp_total, streak_count, longest_streak, last_active_date)
    VALUES (p_user_id, p_xp_amount, 0, 0, CURRENT_DATE)
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        xp_total = user_stats.xp_total + p_xp_amount,
        last_active_date = CURRENT_DATE,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to update user stats with current streaks
CREATE OR REPLACE FUNCTION update_user_streaks(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    streak_data RECORD;
BEGIN
    -- Get current streak data
    SELECT * INTO streak_data FROM calculate_user_streaks(p_user_id);
    
    -- Update user stats with current streaks
    UPDATE user_stats 
    SET 
        streak_count = streak_data.current_streak,
        longest_streak = streak_data.longest_streak,
        updated_at = NOW()
    WHERE user_id = p_user_id;
    
    -- If no user stats exist, create them
    IF NOT FOUND THEN
        INSERT INTO user_stats (user_id, xp_total, streak_count, longest_streak, last_active_date)
        VALUES (p_user_id, 0, streak_data.current_streak, streak_data.longest_streak, CURRENT_DATE);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create function to award streak milestone XP
CREATE OR REPLACE FUNCTION award_streak_milestone_xp(
    p_user_id UUID,
    p_streak_days INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    xp_awarded INTEGER := 0;
BEGIN
    -- Award XP based on streak milestones
    IF p_streak_days = 7 THEN
        xp_awarded := 100;
    ELSIF p_streak_days = 30 THEN
        xp_awarded := 500;
    ELSIF p_streak_days = 100 THEN
        xp_awarded := 2000;
    END IF;
    
    -- If XP should be awarded, update user stats
    IF xp_awarded > 0 THEN
        INSERT INTO user_stats (user_id, xp_total, streak_count, longest_streak, last_active_date)
        VALUES (p_user_id, xp_awarded, p_streak_days, p_streak_days, NOW())
        ON CONFLICT (user_id)
        DO UPDATE SET
            xp_total = user_stats.xp_total + xp_awarded,
            streak_count = p_streak_days,
            longest_streak = GREATEST(user_stats.longest_streak, p_streak_days),
            last_active_date = NOW();
        
        -- Record XP event (only if xp_events table exists)
        BEGIN
            INSERT INTO xp_events (id, user_id, lesson_id, rule_code, awarded_xp, created_at)
            VALUES (
                gen_random_uuid(),
                p_user_id,
                NULL,
                'STREAK_' || p_streak_days || '_DAYS',
                xp_awarded,
                NOW()
            );
        EXCEPTION WHEN undefined_table THEN
            -- xp_events table doesn't exist, skip recording
            NULL;
        END;
    END IF;
    
    RETURN xp_awarded;
END;
$$ LANGUAGE plpgsql;

-- Create function to get user metrics
CREATE OR REPLACE FUNCTION get_user_metrics(p_user_id UUID)
RETURNS TABLE (
    total_xp INTEGER,
    current_streak INTEGER,
    longest_streak INTEGER,
    lessons_completed INTEGER,
    total_study_time_minutes INTEGER,
    quiz_average_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(us.xp_total, 0) as total_xp,
        COALESCE(us.streak_count, 0) as current_streak,
        COALESCE(us.longest_streak, 0) as longest_streak,
        COALESCE(completed_lessons.count, 0) as lessons_completed,
        COALESCE(study_time.total_minutes, 0) as total_study_time_minutes,
        COALESCE(quiz_avg.average_score, 0.0) as quiz_average_score
    FROM user_stats us
    LEFT JOIN (
        SELECT COUNT(*) as count
        FROM user_lesson_progress
        WHERE user_id = p_user_id AND status = 'COMPLETED'
    ) completed_lessons ON true
    LEFT JOIN (
        SELECT SUM(total_time_seconds) / 60 as total_minutes
        FROM daily_usage
        WHERE user_id = p_user_id
    ) study_time ON true
    LEFT JOIN (
        SELECT AVG(score_percentage) as average_score
        FROM lesson_completions
        WHERE user_id = p_user_id
    ) quiz_avg ON true
    WHERE us.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to automatically update streaks when daily usage is recorded
CREATE OR REPLACE FUNCTION trigger_update_user_streaks()
RETURNS TRIGGER AS $$
BEGIN
    -- Update streaks for the user
    PERFORM update_user_streaks(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on daily_usage table
CREATE TRIGGER trigger_daily_usage_update_streaks
    AFTER INSERT OR UPDATE ON daily_usage
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_user_streaks();

-- Grant permissions to authenticated users
GRANT EXECUTE ON FUNCTION record_daily_usage(UUID, DATE, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_user_streak(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_user_streaks(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION increment_user_xp(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION update_user_streaks(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION award_streak_milestone_xp(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_metrics(UUID) TO authenticated;

-- Grant table permissions to authenticated users
GRANT SELECT, INSERT, UPDATE ON daily_usage TO authenticated;
GRANT SELECT, INSERT, UPDATE ON user_stats TO authenticated;
