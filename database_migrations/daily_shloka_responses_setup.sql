-- Daily Shloka Responses Table
-- This table stores user responses to daily shlokas

CREATE TABLE IF NOT EXISTS daily_shloka_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    daily_verse_id UUID NOT NULL REFERENCES daily_verses(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    response_text TEXT,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure one response per user per daily verse
    CONSTRAINT unique_user_daily_verse UNIQUE (user_id, daily_verse_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_daily_shloka_responses_user_id ON daily_shloka_responses(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_shloka_responses_daily_verse_id ON daily_shloka_responses(daily_verse_id);
CREATE INDEX IF NOT EXISTS idx_daily_shloka_responses_date ON daily_shloka_responses(date);
CREATE INDEX IF NOT EXISTS idx_daily_shloka_responses_favorite ON daily_shloka_responses(user_id, is_favorite) WHERE is_favorite = TRUE;

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_daily_shloka_responses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_daily_shloka_responses_updated_at
    BEFORE UPDATE ON daily_shloka_responses
    FOR EACH ROW
    EXECUTE FUNCTION update_daily_shloka_responses_updated_at();

-- Enable RLS (Row Level Security)
ALTER TABLE daily_shloka_responses ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own responses
CREATE POLICY "Users can view their own responses"
    ON daily_shloka_responses
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own responses
CREATE POLICY "Users can insert their own responses"
    ON daily_shloka_responses
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own responses
CREATE POLICY "Users can update their own responses"
    ON daily_shloka_responses
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own responses
CREATE POLICY "Users can delete their own responses"
    ON daily_shloka_responses
    FOR DELETE
    USING (auth.uid() = user_id);

