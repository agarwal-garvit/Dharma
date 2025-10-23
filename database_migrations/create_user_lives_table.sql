-- Migration: Create user_lives table
-- Description: Tracks user lives (0-5) with individual regeneration timestamps for each life

CREATE TABLE public.user_lives (
    user_id uuid NOT NULL,
    current_lives integer NOT NULL DEFAULT 5 CHECK (current_lives >= 0 AND current_lives <= 5),
    life_1_regenerates_at timestamp with time zone,
    life_2_regenerates_at timestamp with time zone,
    life_3_regenerates_at timestamp with time zone,
    life_4_regenerates_at timestamp with time zone,
    life_5_regenerates_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_lives_pkey PRIMARY KEY (user_id),
    CONSTRAINT user_lives_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX idx_user_lives_user_id ON public.user_lives(user_id);

-- Enable Row Level Security
ALTER TABLE public.user_lives ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view and update their own lives
CREATE POLICY "Users can view their own lives"
    ON public.user_lives
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own lives"
    ON public.user_lives
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own lives"
    ON public.user_lives
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Function to automatically initialize lives for new users
CREATE OR REPLACE FUNCTION initialize_user_lives()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_lives (user_id, current_lives)
    VALUES (NEW.id, 5)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to initialize lives when a new user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION initialize_user_lives();

-- Comments for documentation
COMMENT ON TABLE public.user_lives IS 'Tracks user lives for quiz attempts with individual regeneration timestamps';
COMMENT ON COLUMN public.user_lives.current_lives IS 'Current number of lives (0-5)';
COMMENT ON COLUMN public.user_lives.life_1_regenerates_at IS 'Timestamp when life 1 will regenerate (NULL if already active)';
COMMENT ON COLUMN public.user_lives.life_2_regenerates_at IS 'Timestamp when life 2 will regenerate (NULL if already active)';
COMMENT ON COLUMN public.user_lives.life_3_regenerates_at IS 'Timestamp when life 3 will regenerate (NULL if already active)';
COMMENT ON COLUMN public.user_lives.life_4_regenerates_at IS 'Timestamp when life 4 will regenerate (NULL if already active)';
COMMENT ON COLUMN public.user_lives.life_5_regenerates_at IS 'Timestamp when life 5 will regenerate (NULL if already active)';

