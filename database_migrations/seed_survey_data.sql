-- Seed data for survey questions
-- This file contains initial survey questions for the first-time user survey

-- Insert survey questions
INSERT INTO public.survey_questions (id, question_text, question_type, options, order_idx, is_active) VALUES
(
    '550e8400-e29b-41d4-a716-446655440001',
    'How did you hear about Dharma?',
    'MULTIPLE_CHOICE',
    '[
        {"id": "friend_family", "text": "Friend or family"},
        {"id": "social_media", "text": "Social media"},
        {"id": "temple_community", "text": "Temple or community"},
        {"id": "app_store", "text": "App Store"},
        {"id": "other", "text": "Other"}
    ]'::jsonb,
    1,
    true
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'Which of these best describes your connection to Hinduism?',
    'MULTIPLE_CHOICE',
    '[
        {"id": "daily_practice", "text": "I pray or practice daily"},
        {"id": "occasional_traditions", "text": "I follow some traditions occasionally"},
        {"id": "follow_not_practice", "text": "I follow Hinduism but don''t actively practice"},
        {"id": "curious_beginner", "text": "I''m curious and just beginning to explore"},
        {"id": "not_familiar", "text": "I''m not familiar at all"}
    ]'::jsonb,
    2,
    true
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    'What''s your main reason for using Dharma?',
    'MULTIPLE_CHOICE',
    '[
        {"id": "learn_bhagavad_gita", "text": "To learn the teachings of the Bhagavad Gita through lessons"},
        {"id": "daily_verses", "text": "To get daily verses or wisdom"},
        {"id": "ai_chatbot", "text": "To chat with the AI Hinduism chatbot and ask spiritual questions"},
        {"id": "consistent_practice", "text": "To stay consistent in my spiritual practice"},
        {"id": "explore_hinduism", "text": "To explore other aspects of Hinduism"}
    ]'::jsonb,
    3,
    true
),
(
    '550e8400-e29b-41d4-a716-446655440004',
    'Currently, Dharma has only the Bhagavad Gita course. What would you like to see next? (Select up to 3)',
    'MULTI_SELECT',
    '[
        {"id": "upanishads", "text": "The Upanishads"},
        {"id": "vedas", "text": "The Vedas"},
        {"id": "ramayana", "text": "The Ramayana"},
        {"id": "mahabharata", "text": "The Mahabharata (full epic)"},
        {"id": "krishna_stories", "text": "Stories of Krishna"},
        {"id": "shiva_teachings", "text": "Teachings of Lord Shiva"},
        {"id": "hanuman_chalisa", "text": "Hanuman Chalisa"},
        {"id": "yoga_sutras", "text": "Yoga Sutras of Patanjali"},
        {"id": "daily_prayers", "text": "Daily Hindu prayers and mantras"}
    ]'::jsonb,
    4,
    true
),
(
    '550e8400-e29b-41d4-a716-446655440005',
    'How much time would you ideally spend learning per day?',
    'MULTIPLE_CHOICE',
    '[
        {"id": "5_min", "text": "5 minutes"},
        {"id": "10_min", "text": "10 minutes"},
        {"id": "15_20_min", "text": "15–20 minutes"},
        {"id": "more_20_min", "text": "More than 20 minutes"}
    ]'::jsonb,
    5,
    true
);

-- Note: FAQ items are hardcoded in the app, so no seed data needed for FAQ table
