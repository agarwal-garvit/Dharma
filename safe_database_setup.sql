-- Safe Database Setup for Dharma App
-- This script only creates missing tables and objects, avoiding conflicts

-- 1. Create lesson_completions table (if it doesn't exist)
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

-- 2. Create user_lesson_progress table (if it doesn't exist)
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

-- 3. Create user_lesson_sessions table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS user_lesson_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    duration_seconds INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create user_stats table (if it doesn't exist)
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

-- 5. Create xp_events table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS xp_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    rule_code TEXT NOT NULL,
    awarded_xp INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Create indexes (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_lesson_completions_user_id ON lesson_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_lesson_id ON lesson_completions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_user_lesson ON lesson_completions(user_id, lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_attempt_number ON lesson_completions(user_id, lesson_id, attempt_number);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_completed_at ON lesson_completions(completed_at);

CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_user_id ON user_lesson_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_lesson_id ON user_lesson_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_user_lesson ON user_lesson_progress(user_id, lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_status ON user_lesson_progress(status);

CREATE INDEX IF NOT EXISTS idx_user_lesson_sessions_user_id ON user_lesson_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_sessions_lesson_id ON user_lesson_sessions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_sessions_started_at ON user_lesson_sessions(started_at);

CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_events_user_id ON xp_events(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_events_lesson_id ON xp_events(lesson_id);

-- 7. Create unique constraints (only if they don't exist)
CREATE UNIQUE INDEX IF NOT EXISTS idx_lesson_completions_unique_attempt 
ON lesson_completions(user_id, lesson_id, attempt_number);

-- 8. Disable RLS temporarily for testing
ALTER TABLE lesson_completions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_lesson_progress DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_lesson_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE xp_events DISABLE ROW LEVEL SECURITY;

-- 9. Create functions (replace if they exist)
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

CREATE OR REPLACE FUNCTION get_best_lesson_score(p_user_id UUID, p_lesson_id UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    best_score DECIMAL(5,2);
BEGIN
    SELECT MAX(score_percentage)
    INTO best_score
    FROM lesson_completions
    WHERE user_id = p_user_id AND lesson_id = p_lesson_id;
    
    RETURN COALESCE(best_score, 0);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_average_lesson_score(p_user_id UUID, p_lesson_id UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    avg_score DECIMAL(5,2);
BEGIN
    SELECT AVG(score_percentage)
    INTO avg_score
    FROM lesson_completions
    WHERE user_id = p_user_id AND lesson_id = p_lesson_id;
    
    RETURN COALESCE(avg_score, 0);
END;
$$ LANGUAGE plpgsql;

-- 10. Create view (replace if it exists)
CREATE OR REPLACE VIEW lesson_completion_stats AS
SELECT 
    lc.user_id,
    lc.lesson_id,
    l.title as lesson_title,
    COUNT(*) as total_attempts,
    MAX(lc.score_percentage) as best_score,
    AVG(lc.score_percentage) as average_score,
    MIN(lc.time_elapsed_seconds) as fastest_completion,
    AVG(lc.time_elapsed_seconds) as average_completion_time,
    MAX(lc.completed_at) as last_attempt_date
FROM lesson_completions lc
JOIN lessons l ON lc.lesson_id = l.id
GROUP BY lc.user_id, lc.lesson_id, l.title;

-- 11. Grant permissions
GRANT SELECT, INSERT, UPDATE ON lesson_completions TO authenticated;
GRANT SELECT, INSERT, UPDATE ON user_lesson_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE ON user_lesson_sessions TO authenticated;
GRANT SELECT, INSERT, UPDATE ON user_stats TO authenticated;
GRANT SELECT, INSERT, UPDATE ON xp_events TO authenticated;
GRANT SELECT ON lesson_completion_stats TO authenticated;

-- 12. Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION get_next_attempt_number(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_best_lesson_score(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_average_lesson_score(UUID, UUID) TO authenticated;

-- 13. Create trigger function and triggers (with safe handling)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop and recreate triggers safely
DROP TRIGGER IF EXISTS update_lesson_completions_updated_at ON lesson_completions;
CREATE TRIGGER update_lesson_completions_updated_at 
    BEFORE UPDATE ON lesson_completions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_lesson_progress_updated_at ON user_lesson_progress;
CREATE TRIGGER update_user_lesson_progress_updated_at 
    BEFORE UPDATE ON user_lesson_progress 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_stats_updated_at ON user_stats;
CREATE TRIGGER update_user_stats_updated_at 
    BEFORE UPDATE ON user_stats 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
