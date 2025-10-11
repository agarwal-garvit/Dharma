-- Fix Database Issues for Dharma App
-- This script fixes the specific issues found in the logs

-- 1. Fix user_stats table - add missing updated_at column
DO $$ 
BEGIN
    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_stats' AND column_name = 'updated_at') THEN
        ALTER TABLE user_stats ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- 2. Fix user_lesson_progress table - add missing updated_at column
DO $$ 
BEGIN
    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_lesson_progress' AND column_name = 'updated_at') THEN
        ALTER TABLE user_lesson_progress ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- 3. Ensure lesson_completions table exists with correct schema
CREATE TABLE IF NOT EXISTS lesson_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    attempt_number INTEGER NOT NULL DEFAULT 1,
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    score_percentage DECIMAL(5,2) NOT NULL,
    time_elapsed_seconds INTEGER NOT NULL,
    questions_answered JSONB,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Ensure user_lesson_progress table exists with correct schema
CREATE TABLE IF NOT EXISTS user_lesson_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'NOT_STARTED',
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    last_score_pct DECIMAL(5,2),
    best_score_pct DECIMAL(5,2),
    total_completions INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, lesson_id)
);

-- 5. Ensure user_stats table exists with correct schema
CREATE TABLE IF NOT EXISTS user_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    xp_total INTEGER DEFAULT 0,
    streak_count INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_active_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 6. Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_lesson_completions_user_id ON lesson_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_lesson_id ON lesson_completions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_user_lesson ON lesson_completions(user_id, lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_user_id ON user_lesson_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_lesson_id ON user_lesson_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);

-- 7. Disable RLS temporarily for testing
ALTER TABLE lesson_completions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_lesson_progress DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats DISABLE ROW LEVEL SECURITY;

-- 8. Grant permissions
GRANT SELECT, INSERT, UPDATE ON lesson_completions TO authenticated;
GRANT SELECT, INSERT, UPDATE ON user_lesson_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE ON user_stats TO authenticated;

-- 9. Create or replace the get_next_attempt_number function
CREATE OR REPLACE FUNCTION get_next_attempt_number(p_user_id UUID, p_lesson_id UUID)
RETURNS INTEGER AS $$
DECLARE
    next_attempt INTEGER;
BEGIN
    SELECT COALESCE(MAX(attempt_number), 0) + 1
    INTO next_attempt
    FROM lesson_completions
    WHERE user_id = p_user_id AND lesson_id = p_lesson_id;
    
    RETURN next_attempt;
END;
$$ LANGUAGE plpgsql;

-- 10. Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_next_attempt_number(UUID, UUID) TO authenticated;

-- 11. Create or replace the get_user_metrics function with correct return type
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

-- 12. Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_user_metrics(UUID) TO authenticated;

-- 13. Create trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 14. Create triggers for updated_at (drop first to avoid conflicts)
DROP TRIGGER IF EXISTS update_user_stats_updated_at ON user_stats;
CREATE TRIGGER update_user_stats_updated_at 
    BEFORE UPDATE ON user_stats 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_lesson_progress_updated_at ON user_lesson_progress;
CREATE TRIGGER update_user_lesson_progress_updated_at 
    BEFORE UPDATE ON user_lesson_progress 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_lesson_completions_updated_at ON lesson_completions;
CREATE TRIGGER update_lesson_completions_updated_at 
    BEFORE UPDATE ON lesson_completions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
