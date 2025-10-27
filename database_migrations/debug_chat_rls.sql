-- Debug Chat RLS Issues
-- Run this to diagnose chat RLS problems

-- =============================================================================
-- 1. CHECK CURRENT RLS STATUS
-- =============================================================================

-- Check if RLS is enabled on chat tables
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chat_conversations', 'chat_messages');

-- =============================================================================
-- 2. CHECK EXISTING POLICIES
-- =============================================================================

-- Check what policies exist for chat tables
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
AND tablename IN ('chat_conversations', 'chat_messages')
ORDER BY tablename, policyname;

-- =============================================================================
-- 3. CHECK TABLE STRUCTURE
-- =============================================================================

-- Check chat_conversations table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'chat_conversations'
ORDER BY ordinal_position;

-- Check chat_messages table structure  
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'chat_messages'
ORDER BY ordinal_position;

-- =============================================================================
-- 4. TEST AUTHENTICATION CONTEXT
-- =============================================================================

-- Check if auth.uid() is working (run this while authenticated)
SELECT 
    auth.uid() as current_user_id,
    auth.role() as current_role;

-- =============================================================================
-- 5. TEMPORARY DISABLE RLS FOR TESTING
-- =============================================================================

-- Uncomment these lines to temporarily disable RLS for debugging:
-- ALTER TABLE public.chat_conversations DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;

-- Remember to re-enable RLS after testing:
-- ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- 6. CREATE MINIMAL WORKING POLICIES
-- =============================================================================

-- Drop all existing policies first
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies 
        WHERE schemaname = 'public'
        AND tablename IN ('chat_conversations', 'chat_messages')
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- Create minimal working policies
CREATE POLICY "chat_conversations_policy" ON public.chat_conversations
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "chat_messages_policy" ON public.chat_messages
    FOR ALL USING (
        conversation_id IS NULL OR
        EXISTS (
            SELECT 1 FROM public.chat_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

-- =============================================================================
-- 7. VERIFY POLICIES WORK
-- =============================================================================

-- Check the new policies
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
AND tablename IN ('chat_conversations', 'chat_messages')
ORDER BY tablename, policyname;
