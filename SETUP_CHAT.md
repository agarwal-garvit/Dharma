# Chat Setup Instructions

## Database Setup

1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Navigate to your project: https://cifjluhwhifwxiyzyrzx.supabase.co
3. Go to the SQL Editor
4. Copy and paste the contents of `database_setup.sql` and run it

This will create the necessary tables and security policies for the chat functionality.

## What's Been Implemented

### 1. ChatManager
- Real OpenAI API integration using GPT-3.5-turbo
- Database persistence for conversations and messages
- Conversation management (create, load, delete)
- Proper error handling and loading states

### 2. Updated ChatbotView
- Connected to real ChatManager instead of mock responses
- Async message sending
- Real-time loading indicators
- Conversation persistence

### 3. Database Models
- `ChatMessage`: Individual chat messages with conversation linking
- `ChatConversation`: Conversation metadata and management
- Proper UUID relationships and timestamps

### 4. Security
- Row Level Security (RLS) policies ensure users can only access their own conversations
- Proper authentication checks
- Secure API key handling

## Features

- **Real AI Responses**: Uses OpenAI GPT-3.5-turbo for intelligent responses about the Bhagavad Gita
- **Conversation History**: All conversations are saved and can be resumed
- **User Authentication**: Only authenticated users can use the chat
- **Secure**: All data is properly secured with RLS policies
- **Performance**: Indexed database queries for fast loading

## API Key Security

The OpenAI API key is currently hardcoded in the ChatManager. For production, you should:
1. Move the API key to environment variables
2. Use a backend proxy to hide the API key from the client
3. Implement rate limiting and usage monitoring

## Testing

After setting up the database:
1. Make sure you're signed in to the app
2. Navigate to the Chat tab
3. Send a message - you should get a real AI response
4. Check your Supabase database to see the conversation and messages being saved

## Next Steps

- Add conversation history UI
- Implement message search
- Add conversation sharing
- Implement conversation export
- Add typing indicators
- Implement message reactions
