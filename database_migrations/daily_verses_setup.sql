-- Daily Verses Table Setup
-- This table stores daily verses that will be displayed in the Daily feature

CREATE TABLE IF NOT EXISTS daily_verses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL UNIQUE,
    verse_id VARCHAR(255) NOT NULL,
    chapter_index INTEGER NOT NULL,
    verse_index INTEGER NOT NULL,
    devanagari_text TEXT NOT NULL,
    iast_text TEXT NOT NULL,
    translation_en TEXT NOT NULL,
    keywords TEXT[] DEFAULT '{}',
    themes TEXT[] DEFAULT '{}',
    commentary_short TEXT,
    audio_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on date for fast lookups
CREATE INDEX IF NOT EXISTS idx_daily_verses_date ON daily_verses(date);

-- Create index on verse reference for easy lookups
CREATE INDEX IF NOT EXISTS idx_daily_verses_verse_ref ON daily_verses(chapter_index, verse_index);

-- Add RLS (Row Level Security) policies if needed
-- ALTER TABLE daily_verses ENABLE ROW LEVEL SECURITY;

-- Create a function to get daily verse by date
CREATE OR REPLACE FUNCTION get_daily_verse_by_date(p_date DATE)
RETURNS TABLE (
    id UUID,
    date DATE,
    verse_id VARCHAR(255),
    chapter_index INTEGER,
    verse_index INTEGER,
    devanagari_text TEXT,
    iast_text TEXT,
    translation_en TEXT,
    keywords TEXT[],
    themes TEXT[],
    commentary_short TEXT,
    audio_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dv.id,
        dv.date,
        dv.verse_id,
        dv.chapter_index,
        dv.verse_index,
        dv.devanagari_text,
        dv.iast_text,
        dv.translation_en,
        dv.keywords,
        dv.themes,
        dv.commentary_short,
        dv.audio_url,
        dv.created_at,
        dv.updated_at
    FROM daily_verses dv
    WHERE dv.date = p_date;
END;
$$ LANGUAGE plpgsql;

-- Create a function to get daily verse by day of year (for cycling through verses)
CREATE OR REPLACE FUNCTION get_daily_verse_by_day_of_year(p_day_of_year INTEGER)
RETURNS TABLE (
    id UUID,
    date DATE,
    verse_id VARCHAR(255),
    chapter_index INTEGER,
    verse_index INTEGER,
    devanagari_text TEXT,
    iast_text TEXT,
    translation_en TEXT,
    keywords TEXT[],
    themes TEXT[],
    commentary_short TEXT,
    audio_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dv.id,
        dv.date,
        dv.verse_id,
        dv.chapter_index,
        dv.verse_index,
        dv.devanagari_text,
        dv.iast_text,
        dv.translation_en,
        dv.keywords,
        dv.themes,
        dv.commentary_short,
        dv.audio_url,
        dv.created_at,
        dv.updated_at
    FROM daily_verses dv
    ORDER BY dv.date
    LIMIT 1
    OFFSET ((p_day_of_year - 1) % (SELECT COUNT(*) FROM daily_verses));
END;
$$ LANGUAGE plpgsql;

-- Create a function to get the next available daily verse
CREATE OR REPLACE FUNCTION get_next_daily_verse()
RETURNS TABLE (
    id UUID,
    date DATE,
    verse_id VARCHAR(255),
    chapter_index INTEGER,
    verse_index INTEGER,
    devanagari_text TEXT,
    iast_text TEXT,
    translation_en TEXT,
    keywords TEXT[],
    themes TEXT[],
    commentary_short TEXT,
    audio_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dv.id,
        dv.date,
        dv.verse_id,
        dv.chapter_index,
        dv.verse_index,
        dv.devanagari_text,
        dv.iast_text,
        dv.translation_en,
        dv.keywords,
        dv.themes,
        dv.commentary_short,
        dv.audio_url,
        dv.created_at,
        dv.updated_at
    FROM daily_verses dv
    WHERE dv.date >= CURRENT_DATE
    ORDER BY dv.date
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
