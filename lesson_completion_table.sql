-- Create comprehensive lesson completion tracking table
-- This table captures all details about a completed lesson attempt

CREATE TABLE IF NOT EXISTS lesson_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    attempt_number INTEGER NOT NULL DEFAULT 1,
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    score_percentage DECIMAL(5,2) NOT NULL,
    time_elapsed_seconds INTEGER NOT NULL,
    questions_answered JSONB, -- Store individual question responses
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_lesson_completions_user_id ON lesson_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_lesson_id ON lesson_completions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_user_lesson ON lesson_completions(user_id, lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_attempt_number ON lesson_completions(user_id, lesson_id, attempt_number);
CREATE INDEX IF NOT EXISTS idx_lesson_completions_completed_at ON lesson_completions(completed_at);

-- Create a unique constraint to prevent duplicate attempts
CREATE UNIQUE INDEX IF NOT EXISTS idx_lesson_completions_unique_attempt 
ON lesson_completions(user_id, lesson_id, attempt_number);

-- Enable Row Level Security (RLS)
ALTER TABLE lesson_completions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own lesson completions" ON lesson_completions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own lesson completions" ON lesson_completions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own lesson completions" ON lesson_completions
    FOR UPDATE USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_lesson_completions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_lesson_completions_updated_at 
    BEFORE UPDATE ON lesson_completions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_lesson_completions_updated_at();

-- Create function to get next attempt number for a user/lesson combination
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

-- Create function to get user's best score for a lesson
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

-- Create function to get user's average score for a lesson
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

-- Create view for lesson completion statistics
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

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE ON lesson_completions TO authenticated;
GRANT SELECT ON lesson_completion_stats TO authenticated;
