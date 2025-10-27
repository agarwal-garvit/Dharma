-- Test Chat RLS Policies
-- Run this to verify chat RLS is working correctly

-- =============================================================================
-- 1. CHECK AUTHENTICATION CONTEXT
-- =============================================================================

-- This should show your current user ID and role
SELECT 
    auth.uid() as current_user_id,
    auth.role() as current_role,
    now() as current_timestamp;

-- =============================================================================
-- 2. TEST CONVERSATION INSERT (should work if authenticated)
-- =============================================================================

-- Test inserting a conversation (replace with actual user ID)
-- This should work if you're authenticated
INSERT INTO public.chat_conversations (id, user_id, title, created_at, updated_at, message_count)
VALUES (
    gen_random_uuid(),
    auth.uid(),  -- This will use the current authenticated user
    'Test Conversation',
    now(),
    now(),
    0
);

-- =============================================================================
-- 3. TEST MESSAGE INSERT (should work if conversation belongs to user)
-- =============================================================================

-- Get the conversation ID we just created
WITH test_conversation AS (
    SELECT id FROM public.chat_conversations 
    WHERE user_id = auth.uid() 
    ORDER BY created_at DESC 
    LIMIT 1
)
-- Insert a test message
INSERT INTO public.chat_messages (id, conversation_id, content, is_user, timestamp)
SELECT 
    gen_random_uuid(),
    test_conversation.id,
    'Test message',
    true,
    now()
FROM test_conversation;

-- =============================================================================
-- 4. VERIFY DATA ISOLATION
-- =============================================================================

-- This should only show conversations for the current user
SELECT 
    id,
    user_id,
    title,
    created_at
FROM public.chat_conversations 
WHERE user_id = auth.uid()
ORDER BY created_at DESC;

-- This should only show messages from the current user's conversations
SELECT 
    m.id,
    m.conversation_id,
    m.content,
    m.is_user,
    m.timestamp,
    c.title as conversation_title
FROM public.chat_messages m
JOIN public.chat_conversations c ON m.conversation_id = c.id
WHERE c.user_id = auth.uid()
ORDER BY m.timestamp DESC;

-- =============================================================================
-- 5. CLEANUP TEST DATA
-- =============================================================================

-- Clean up the test data we created
DELETE FROM public.chat_messages 
WHERE content = 'Test message';

DELETE FROM public.chat_conversations 
WHERE title = 'Test Conversation';

-- =============================================================================
-- 6. CHECK FOR ANY REMAINING ISSUES
-- =============================================================================

-- Check if there are any policies that might be conflicting
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

-- Check table constraints
SELECT 
    tc.constraint_name,
    tc.table_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public' 
AND tc.table_name IN ('chat_conversations', 'chat_messages')
ORDER BY tc.table_name, tc.constraint_type;
