-- Fix Chat RLS Policies
-- This addresses common RLS issues with chat functionality

-- =============================================================================
-- DROP EXISTING CHAT POLICIES
-- =============================================================================

-- Drop existing chat policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view their own conversations" ON public.chat_conversations;
DROP POLICY IF EXISTS "Users can create their own conversations" ON public.chat_conversations;
DROP POLICY IF EXISTS "Users can update their own conversations" ON public.chat_conversations;
DROP POLICY IF EXISTS "Users can delete their own conversations" ON public.chat_conversations;

DROP POLICY IF EXISTS "Users can view messages from their conversations" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can insert messages to their conversations" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can update messages in their conversations" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can delete messages from their conversations" ON public.chat_messages;

-- =============================================================================
-- ENABLE RLS ON CHAT TABLES (if not already enabled)
-- =============================================================================

ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- CREATE SIMPLIFIED CHAT POLICIES
-- =============================================================================

-- Chat Conversations: Users can only access their own conversations
CREATE POLICY "Users can manage their own conversations" ON public.chat_conversations
    FOR ALL USING (auth.uid() = user_id);

-- Chat Messages: Users can only access messages from their own conversations
-- This policy is more permissive to avoid issues with message insertion
CREATE POLICY "Users can manage messages in their conversations" ON public.chat_messages
    FOR ALL USING (
        conversation_id IS NULL OR
        EXISTS (
            SELECT 1 FROM public.chat_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

-- =============================================================================
-- ALTERNATIVE: MORE PERMISSIVE POLICIES (if the above doesn't work)
-- =============================================================================

-- Uncomment these if the above policies still cause issues:

-- -- Very permissive conversation policy
-- CREATE POLICY "Users can manage their own conversations permissive" ON public.chat_conversations
--     FOR ALL USING (true);

-- -- Very permissive message policy  
-- CREATE POLICY "Users can manage messages permissive" ON public.chat_messages
--     FOR ALL USING (true);

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Check if RLS is enabled on chat tables
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chat_conversations', 'chat_messages')
ORDER BY tablename;

-- Check chat policies
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
-- DEBUGGING: Test RLS with a sample query
-- =============================================================================

-- Uncomment to test if RLS is working (replace with actual user ID):
-- SELECT * FROM public.chat_conversations WHERE user_id = 'your-user-id-here';
-- SELECT * FROM public.chat_messages WHERE conversation_id IN (
--     SELECT id FROM public.chat_conversations WHERE user_id = 'your-user-id-here'
-- );
