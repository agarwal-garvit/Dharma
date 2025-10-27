-- RLS (Row Level Security) Policies for Dharma App
-- Based on the actual tables in database_setup.sql
-- Run this in Supabase SQL Editor

-- =============================================================================
-- CLEAN UP EXISTING POLICIES (to avoid conflicts/duplicates)
-- =============================================================================

-- Drop all existing policies on all tables
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Loop through all tables in public schema
    FOR r IN (
        SELECT schemaname, tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    ) LOOP
        -- Drop all policies for each table
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own profile" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can update their own profile" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own profile" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own stats" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can update their own stats" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own stats" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own lives" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can update their own lives" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own lives" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own login sessions" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own login sessions" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own lesson completions" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own lesson completions" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own XP events" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own XP events" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own survey responses" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own survey responses" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can update their own survey responses" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own feedback" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert their own feedback" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view their own conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can create their own conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can update their own conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can delete their own conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can view messages from their conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can insert messages to their conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can update messages in their conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Users can delete messages from their conversations" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Courses are viewable by authenticated users" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Lessons are viewable by authenticated users" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Lesson sections are viewable by authenticated users" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "XP rules are viewable by authenticated users" ON %I.%I', r.schemaname, r.tablename);
        EXECUTE format('DROP POLICY IF EXISTS "Survey questions are viewable by authenticated users" ON %I.%I', r.schemaname, r.tablename);
    END LOOP;
END $$;

-- Alternative approach: Drop all policies using a more comprehensive method
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Get all policies and drop them
    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies 
        WHERE schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- =============================================================================
-- ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- =============================================================================

-- Core content tables (readable by all authenticated users)
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_rules ENABLE ROW LEVEL SECURITY;

-- User-specific tables (users can only access their own data)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_lives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_login_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_events ENABLE ROW LEVEL SECURITY;

-- Survey tables (already have RLS from create_survey_tables.sql)
-- These are already enabled, but let's make sure they're consistent
ALTER TABLE public.survey_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_feedback ENABLE ROW LEVEL SECURITY;

-- Chat tables (users can only access their own conversations)
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- CREATE RLS POLICIES
-- =============================================================================

-- =============================================================================
-- CORE CONTENT TABLES (Read-only for authenticated users)
-- =============================================================================

-- Courses: All authenticated users can read
CREATE POLICY "Courses are viewable by authenticated users" ON public.courses
    FOR SELECT USING (auth.role() = 'authenticated');

-- Lessons: All authenticated users can read
CREATE POLICY "Lessons are viewable by authenticated users" ON public.lessons
    FOR SELECT USING (auth.role() = 'authenticated');

-- Lesson sections: All authenticated users can read
CREATE POLICY "Lesson sections are viewable by authenticated users" ON public.lesson_sections
    FOR SELECT USING (auth.role() = 'authenticated');

-- XP rules: All authenticated users can read
CREATE POLICY "XP rules are viewable by authenticated users" ON public.xp_rules
    FOR SELECT USING (auth.role() = 'authenticated');

-- =============================================================================
-- USER-SPECIFIC TABLES (Users can only access their own data)
-- =============================================================================

-- Users table: Users can only access their own profile
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- User stats: Users can only access their own stats
CREATE POLICY "Users can view their own stats" ON public.user_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own stats" ON public.user_stats
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own stats" ON public.user_stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User lives: Users can only access their own lives
CREATE POLICY "Users can view their own lives" ON public.user_lives
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own lives" ON public.user_lives
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own lives" ON public.user_lives
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User login sessions: Users can only access their own login history
CREATE POLICY "Users can view their own login sessions" ON public.user_login_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own login sessions" ON public.user_login_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Lesson completions: Users can only access their own completions
CREATE POLICY "Users can view their own lesson completions" ON public.lesson_completions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own lesson completions" ON public.lesson_completions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- XP events: Users can only access their own XP events
CREATE POLICY "Users can view their own XP events" ON public.xp_events
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own XP events" ON public.xp_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =============================================================================
-- SURVEY TABLES (Already have policies, but let's ensure consistency)
-- =============================================================================

-- Survey questions: All authenticated users can read
CREATE POLICY "Survey questions are viewable by authenticated users" ON public.survey_questions
    FOR SELECT USING (auth.role() = 'authenticated');

-- Survey responses: Users can only access their own responses
CREATE POLICY "Users can view their own survey responses" ON public.survey_responses
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own survey responses" ON public.survey_responses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own survey responses" ON public.survey_responses
    FOR UPDATE USING (auth.uid() = user_id);

-- User feedback: Users can only submit and view their own feedback
CREATE POLICY "Users can view their own feedback" ON public.user_feedback
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own feedback" ON public.user_feedback
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =============================================================================
-- CHAT TABLES (Users can only access their own conversations)
-- =============================================================================

-- Chat conversations: Users can only access their own conversations
CREATE POLICY "Users can view their own conversations" ON public.chat_conversations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own conversations" ON public.chat_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own conversations" ON public.chat_conversations
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own conversations" ON public.chat_conversations
    FOR DELETE USING (auth.uid() = user_id);

-- Chat messages: Users can only access messages from their own conversations
CREATE POLICY "Users can view messages from their conversations" ON public.chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert messages to their conversations" ON public.chat_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.chat_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update messages in their conversations" ON public.chat_messages
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.chat_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete messages from their conversations" ON public.chat_messages
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.chat_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Check which tables have RLS enabled
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Check which policies were created
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd as "Operation",
    qual as "Condition"
FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename, policyname;

-- =============================================================================
-- NOTES
-- =============================================================================

/*
This RLS setup provides:

1. PUBLIC CONTENT (readable by all authenticated users):
   - courses, lessons, lesson_sections, xp_rules, survey_questions

2. USER-SPECIFIC DATA (users can only access their own data):
   - users, user_stats, user_lives, user_login_sessions
   - lesson_completions, xp_events, survey_responses, user_feedback

3. CHAT DATA (users can only access their own conversations):
   - chat_conversations, chat_messages

The policies use:
- auth.uid() = user_id: Users can only access their own data
- auth.role() = 'authenticated': Any signed-in user can read public content
- EXISTS subqueries: For chat messages, ensuring users can only access messages from their own conversations

Your Swift code will work exactly the same - RLS is transparent to the application layer.
*/
