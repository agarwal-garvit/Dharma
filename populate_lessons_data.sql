-- Populate Dharma database with sample course and lessons data
-- Run this in your Supabase SQL editor after creating the tables

-- Insert XP rules first
INSERT INTO public.xp_rules (code, xp_amount) VALUES
('LESSON_COMPLETE', 50),
('QUIZ_CORRECT', 10),
('QUIZ_PERFECT', 25),
('STREAK_DAILY', 20),
('STREAK_WEEKLY', 100),
('STREAK_MONTHLY', 500)
ON CONFLICT (code) DO NOTHING;

-- Insert a sample course
INSERT INTO public.courses (id, title, description) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Bhagavad Gita', 'The Song of God - 700 verses of spiritual wisdom from the Mahabharata')
ON CONFLICT (id) DO NOTHING;

-- Insert 18 lessons for the Bhagavad Gita course
INSERT INTO public.lessons (id, course_id, order_idx, title) VALUES
-- Chapter 1: Arjuna's Despair
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 1, 'Arjuna''s Despair'),
-- Chapter 2: Sankhya Yoga
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 2, 'Sankhya Yoga'),
-- Chapter 3: Karma Yoga
('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 3, 'Karma Yoga'),
-- Chapter 4: Jnana Yoga
('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 4, 'Jnana Yoga'),
-- Chapter 5: Karma Sannyasa Yoga
('550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440000', 5, 'Karma Sannyasa Yoga'),
-- Chapter 6: Dhyana Yoga
('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440000', 6, 'Dhyana Yoga'),
-- Chapter 7: Jnana Vijnana Yoga
('550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440000', 7, 'Jnana Vijnana Yoga'),
-- Chapter 8: Akshara Brahma Yoga
('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440000', 8, 'Akshara Brahma Yoga'),
-- Chapter 9: Raja Vidya Yoga
('550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440000', 9, 'Raja Vidya Yoga'),
-- Chapter 10: Vibhuti Yoga
('550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440000', 10, 'Vibhuti Yoga'),
-- Chapter 11: Vishvarupa Darshana Yoga
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440000', 11, 'Vishvarupa Darshana Yoga'),
-- Chapter 12: Bhakti Yoga
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440000', 12, 'Bhakti Yoga'),
-- Chapter 13: Kshetra Kshetrajna Yoga
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440000', 13, 'Kshetra Kshetrajna Yoga'),
-- Chapter 14: Gunatraya Vibhaga Yoga
('550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440000', 14, 'Gunatraya Vibhaga Yoga'),
-- Chapter 15: Purushottama Yoga
('550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440000', 15, 'Purushottama Yoga'),
-- Chapter 16: Daivasura Sampad Vibhaga Yoga
('550e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440000', 16, 'Daivasura Sampad Vibhaga Yoga'),
-- Chapter 17: Shraddhatraya Vibhaga Yoga
('550e8400-e29b-41d4-a716-446655440017', '550e8400-e29b-41d4-a716-446655440000', 17, 'Shraddhatraya Vibhaga Yoga'),
-- Chapter 18: Moksha Sannyasa Yoga
('550e8400-e29b-41d4-a716-446655440018', '550e8400-e29b-41d4-a716-446655440000', 18, 'Moksha Sannyasa Yoga')
ON CONFLICT (id) DO NOTHING;

-- Insert lesson sections for each lesson (Summary, Quiz, Final Thoughts, Closing Prayer)
-- We'll create 4 sections per lesson (72 total sections)

-- Lesson 1 sections
INSERT INTO public.lesson_sections (id, lesson_id, kind, order_idx, content) VALUES
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "In this chapter, Arjuna faces a moral dilemma on the battlefield of Kurukshetra. He sees his relatives, teachers, and friends on both sides and becomes overwhelmed with grief and confusion. This chapter sets the stage for the entire Bhagavad Gita as Krishna begins to guide Arjuna through his spiritual crisis."}'),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440001', 'QUIZ', 2, '{"title": "Understanding Arjuna''s Dilemma", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440001', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider how Arjuna''s dilemma reflects universal human struggles with duty, morality, and difficult decisions."}'),
('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440001', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we find clarity in our own moments of confusion and seek guidance when facing difficult choices."}'),

-- Lesson 2 sections
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440002', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna begins teaching Arjuna about the eternal nature of the soul and the importance of fulfilling one''s duty without attachment to results. This chapter introduces key concepts of Sankhya philosophy and the path of knowledge."}'),
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440002', 'QUIZ', 2, '{"title": "Sankhya Philosophy", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440002', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the concept of duty and how we can perform our responsibilities without being attached to outcomes."}'),
('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440002', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we understand our true nature and fulfill our duties with wisdom and detachment."}'),

-- Lesson 3 sections
('550e8400-e29b-41d4-a716-446655440301', '550e8400-e29b-41d4-a716-446655440003', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna explains the path of Karma Yoga - selfless action performed as a service to the divine. This chapter emphasizes the importance of action over inaction and teaches how to work without attachment to results."}'),
('550e8400-e29b-41d4-a716-446655440302', '550e8400-e29b-41d4-a716-446655440003', 'QUIZ', 2, '{"title": "Karma Yoga Principles", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440303', '550e8400-e29b-41d4-a716-446655440003', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider how you can apply the principles of selfless action in your daily life and work."}'),
('550e8400-e29b-41d4-a716-446655440304', '550e8400-e29b-41d4-a716-446655440003', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we learn to work selflessly and find fulfillment in serving others and the divine."}'),

-- Lesson 4 sections
('550e8400-e29b-41d4-a716-446655440401', '550e8400-e29b-41d4-a716-446655440004', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna reveals his divine nature and explains the path of Jnana Yoga - the yoga of knowledge. He describes how he has appeared in many forms throughout history to restore dharma and guide humanity."}'),
('550e8400-e29b-41d4-a716-446655440402', '550e8400-e29b-41d4-a716-446655440004', 'QUIZ', 2, '{"title": "Divine Manifestations", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440403', '550e8400-e29b-41d4-a716-446655440004', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the concept of divine intervention and how wisdom and knowledge can guide us through difficult times."}'),
('550e8400-e29b-41d4-a716-446655440404', '550e8400-e29b-41d4-a716-446655440004', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we seek knowledge and wisdom to understand our true purpose and the divine plan."}'),

-- Lesson 5 sections
('550e8400-e29b-41d4-a716-446655440501', '550e8400-e29b-41d4-a716-446655440005', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna explains the path of Karma Sannyasa Yoga - renunciation of action through knowledge. He clarifies that true renunciation is not about abandoning action but about performing action without attachment."}'),
('550e8400-e29b-41d4-a716-446655440502', '550e8400-e29b-41d4-a716-446655440005', 'QUIZ', 2, '{"title": "True Renunciation", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440503', '550e8400-e29b-41d4-a716-446655440005', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider the difference between physical renunciation and mental detachment from the fruits of action."}'),
('550e8400-e29b-41d4-a716-446655440504', '550e8400-e29b-41d4-a716-446655440005', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we learn to act with wisdom and detachment, finding peace in the performance of our duties."}'),

-- Lesson 6 sections
('550e8400-e29b-41d4-a716-446655440601', '550e8400-e29b-41d4-a716-446655440006', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna teaches about Dhyana Yoga - the yoga of meditation. He explains the practice of meditation, the qualities of a true yogi, and how to achieve mental control and inner peace."}'),
('550e8400-e29b-41d4-a716-446655440602', '550e8400-e29b-41d4-a716-446655440006', 'QUIZ', 2, '{"title": "Meditation Practice", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440603', '550e8400-e29b-41d4-a716-446655440006', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the importance of meditation and mental discipline in achieving inner peace and spiritual growth."}'),
('550e8400-e29b-41d4-a716-446655440604', '550e8400-e29b-41d4-a716-446655440006', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we develop the discipline of meditation and find inner peace through regular spiritual practice."}'),

-- Lesson 7 sections
('550e8400-e29b-41d4-a716-446655440701', '550e8400-e29b-41d4-a716-446655440007', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna reveals the combination of Jnana (knowledge) and Vijnana (realization). He explains his divine nature, the source of all creation, and how everything emanates from him."}'),
('550e8400-e29b-41d4-a716-446655440702', '550e8400-e29b-41d4-a716-446655440007', 'QUIZ', 2, '{"title": "Divine Nature", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440703', '550e8400-e29b-41d4-a716-446655440007', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider the relationship between knowledge and realization, and how understanding leads to deeper spiritual insight."}'),
('550e8400-e29b-41d4-a716-446655440704', '550e8400-e29b-41d4-a716-446655440007', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we seek both knowledge and realization to understand the divine nature within and around us."}'),

-- Lesson 8 sections
('550e8400-e29b-41d4-a716-446655440801', '550e8400-e29b-41d4-a716-446655440008', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna explains the nature of the eternal, imperishable Brahman and the process of death and rebirth. He teaches about the supreme goal and how to achieve it through devotion and meditation."}'),
('550e8400-e29b-41d4-a716-446655440802', '550e8400-e29b-41d4-a716-446655440008', 'QUIZ', 2, '{"title": "Eternal Brahman", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440803', '550e8400-e29b-41d4-a716-446655440008', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the eternal nature of the soul and the temporary nature of the physical body."}'),
('550e8400-e29b-41d4-a716-446655440804', '550e8400-e29b-41d4-a716-446655440008', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we understand our eternal nature and seek the supreme goal of spiritual realization."}'),

-- Lesson 9 sections
('550e8400-e29b-41d4-a716-446655440901', '550e8400-e29b-41d4-a716-446655440009', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna reveals the royal secret of devotion - the most confidential knowledge. He explains how everything in creation is a part of him and how devotion is the easiest path to reach him."}'),
('550e8400-e29b-41d4-a716-446655440902', '550e8400-e29b-41d4-a716-446655440009', 'QUIZ', 2, '{"title": "Royal Secret", "questions": []}'),
('550e8400-e29b-41d4-a716-446655440903', '550e8400-e29b-41d4-a716-446655440009', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider the power of devotion and how love and faith can be the most direct path to spiritual realization."}'),
('550e8400-e29b-41d4-a716-446655440904', '550e8400-e29b-41d4-a716-446655440009', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we develop pure devotion and find the divine in all aspects of creation."}'),

-- Lesson 10 sections
('550e8400-e29b-41d4-a716-446655441001', '550e8400-e29b-41d4-a716-446655440010', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna describes his divine glories and manifestations throughout the universe. He explains how he is the source of all power, beauty, and knowledge, and how everything emanates from his divine nature."}'),
('550e8400-e29b-41d4-a716-446655441002', '550e8400-e29b-41d4-a716-446655440010', 'QUIZ', 2, '{"title": "Divine Glories", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441003', '550e8400-e29b-41d4-a716-446655440010', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the divine presence in all aspects of nature and creation around us."}'),
('550e8400-e29b-41d4-a716-446655441004', '550e8400-e29b-41d4-a716-446655440010', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we recognize the divine in all creation and develop reverence for the sacred in everyday life."}'),

-- Lesson 11 sections
('550e8400-e29b-41d4-a716-446655441101', '550e8400-e29b-41d4-a716-446655440011', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna reveals his universal form to Arjuna, showing the cosmic manifestation of his divine nature. This is one of the most dramatic and profound chapters, revealing the infinite scope of divine reality."}'),
('550e8400-e29b-41d4-a716-446655441102', '550e8400-e29b-41d4-a716-446655440011', 'QUIZ', 2, '{"title": "Universal Form", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441103', '550e8400-e29b-41d4-a716-446655440011', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider the vastness of divine reality and how our individual perspective relates to the cosmic whole."}'),
('550e8400-e29b-41d4-a716-446655441104', '550e8400-e29b-41d4-a716-446655440011', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we develop the vision to see beyond our limited perspective and recognize the infinite nature of reality."}'),

-- Lesson 12 sections
('550e8400-e29b-41d4-a716-446655441201', '550e8400-e29b-41d4-a716-446655440012', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna explains the path of Bhakti Yoga - the yoga of devotion. He describes the qualities of a true devotee and how devotion is the most accessible path for all people to reach the divine."}'),
('550e8400-e29b-41d4-a716-446655441202', '550e8400-e29b-41d4-a716-446655440012', 'QUIZ', 2, '{"title": "Path of Devotion", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441203', '550e8400-e29b-41d4-a716-446655440012', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the power of love and devotion in spiritual practice and daily life."}'),
('550e8400-e29b-41d4-a716-446655441204', '550e8400-e29b-41d4-a716-446655440012', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we cultivate pure devotion and find the divine through love and surrender."}'),

-- Lesson 13 sections
('550e8400-e29b-41d4-a716-446655441301', '550e8400-e29b-41d4-a716-446655440013', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna explains the distinction between the field (Kshetra) and the knower of the field (Kshetrajna). This chapter deals with the nature of the body, mind, and soul, and the process of self-realization."}'),
('550e8400-e29b-41d4-a716-446655441302', '550e8400-e29b-41d4-a716-446655440013', 'QUIZ', 2, '{"title": "Field and Knower", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441303', '550e8400-e29b-41d4-a716-446655440013', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider the distinction between the temporary body and the eternal soul, and how this understanding affects our perspective on life."}'),
('550e8400-e29b-41d4-a716-446655441304', '550e8400-e29b-41d4-a716-446655440013', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we develop the wisdom to distinguish between the temporary and the eternal, and find our true nature."}'),

-- Lesson 14 sections
('550e8400-e29b-41d4-a716-446655441401', '550e8400-e29b-41d4-a716-446655440014', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna explains the three gunas (qualities) of nature: Sattva (goodness), Rajas (passion), and Tamas (ignorance). He describes how these qualities bind the soul and how to transcend them."}'),
('550e8400-e29b-41d4-a716-446655441402', '550e8400-e29b-41d4-a716-446655440014', 'QUIZ', 2, '{"title": "Three Gunas", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441403', '550e8400-e29b-41d4-a716-446655440014', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on how the three gunas influence your thoughts, actions, and decisions in daily life."}'),
('550e8400-e29b-41d4-a716-446655441404', '550e8400-e29b-41d4-a716-446655440014', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we develop the awareness to recognize the influence of the gunas and transcend their limitations."}'),

-- Lesson 15 sections
('550e8400-e29b-41d4-a716-446655441501', '550e8400-e29b-41d4-a716-446655440015', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna describes the cosmic tree of life and explains the concept of Purushottama - the Supreme Person. He reveals the ultimate goal of spiritual practice and the nature of the highest reality."}'),
('550e8400-e29b-41d4-a716-446655441502', '550e8400-e29b-41d4-a716-446655440015', 'QUIZ', 2, '{"title": "Supreme Person", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441503', '550e8400-e29b-41d4-a716-446655440015', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider the ultimate goal of spiritual practice and what it means to realize the Supreme Person."}'),
('550e8400-e29b-41d4-a716-446655441504', '550e8400-e29b-41d4-a716-446655440015', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we seek the highest truth and realize our connection to the Supreme Person."}'),

-- Lesson 16 sections
('550e8400-e29b-41d4-a716-446655441601', '550e8400-e29b-41d4-a716-446655440016', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna describes the divine and demonic qualities that exist in human nature. He explains how divine qualities lead to liberation while demonic qualities lead to bondage and suffering."}'),
('550e8400-e29b-41d4-a716-446655441602', '550e8400-e29b-41d4-a716-446655440016', 'QUIZ', 2, '{"title": "Divine vs Demonic", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441603', '550e8400-e29b-41d4-a716-446655440016', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the divine and demonic qualities within yourself and how to cultivate the divine while transcending the demonic."}'),
('550e8400-e29b-41d4-a716-446655441604', '550e8400-e29b-41d4-a716-446655440016', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we cultivate divine qualities and overcome the tendencies that lead to suffering and bondage."}'),

-- Lesson 17 sections
('550e8400-e29b-41d4-a716-446655441701', '550e8400-e29b-41d4-a716-446655440017', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "Krishna explains the three types of faith (Shraddha) based on the three gunas. He describes how different types of faith lead to different spiritual practices and outcomes."}'),
('550e8400-e29b-41d4-a716-446655441702', '550e8400-e29b-41d4-a716-446655440017', 'QUIZ', 2, '{"title": "Three Types of Faith", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441703', '550e8400-e29b-41d4-a716-446655440017', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Consider the nature of your own faith and how it influences your spiritual practices and worldview."}'),
('550e8400-e29b-41d4-a716-446655441704', '550e8400-e29b-41d4-a716-446655440017', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we develop pure faith that leads to wisdom, compassion, and spiritual growth."}'),

-- Lesson 18 sections
('550e8400-e29b-41d4-a716-446655441801', '550e8400-e29b-41d4-a716-446655440018', 'SUMMARY', 1, '{"title": "Chapter Summary", "content": "In the final chapter, Krishna summarizes all the teachings and explains the path of Moksha Sannyasa - renunciation that leads to liberation. He concludes with the ultimate message of surrender and devotion."}'),
('550e8400-e29b-41d4-a716-446655441802', '550e8400-e29b-41d4-a716-446655440018', 'QUIZ', 2, '{"title": "Final Teaching", "questions": []}'),
('550e8400-e29b-41d4-a716-446655441803', '550e8400-e29b-41d4-a716-446655440018', 'FINAL_THOUGHTS', 3, '{"title": "Reflection", "content": "Reflect on the entire journey through the Bhagavad Gita and how these teachings can transform your life."}'),
('550e8400-e29b-41d4-a716-446655441804', '550e8400-e29b-41d4-a716-446655440018', 'CLOSING_PRAYER', 4, '{"title": "Prayer", "content": "May we integrate these timeless teachings into our lives and find the peace and wisdom that comes from true understanding."}')
ON CONFLICT (id) DO NOTHING;

-- Insert some sample quiz questions for a few lessons
-- Quiz questions for Lesson 1
INSERT INTO public.quiz_questions (id, section_id, idx, stem, qtype, explanation) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440102', 1, 'What is Arjuna''s main concern at the beginning of the Bhagavad Gita?', 'MCQ_SINGLE', 'Arjuna is overwhelmed by the prospect of fighting against his own relatives, teachers, and friends.'),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440102', 2, 'True or False: Arjuna wants to fight the battle from the beginning.', 'TRUEFALSE', 'False. Arjuna is reluctant to fight and wants to abandon the battle.'),
('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440102', 3, 'What does Krishna represent in the Bhagavad Gita?', 'MCQ_SINGLE', 'Krishna represents the divine teacher and guide who helps Arjuna understand his duty and the nature of reality.')
ON CONFLICT (id) DO NOTHING;

-- Quiz options for Lesson 1 questions
INSERT INTO public.quiz_options (id, question_id, idx, option_text, is_correct) VALUES
-- Question 1 options
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 1, 'He is afraid of losing the battle', false),
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440001', 2, 'He doesn''t want to fight his relatives and teachers', true),
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440001', 3, 'He is not prepared for war', false),
('550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440001', 4, 'He wants to negotiate peace', false),

-- Question 2 options
('550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440002', 1, 'True', false),
('550e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440002', 2, 'False', true),

-- Question 3 options
('550e8400-e29b-41d4-a716-446655440017', '550e8400-e29b-41d4-a716-446655440003', 1, 'A warrior prince', false),
('550e8400-e29b-41d4-a716-446655440018', '550e8400-e29b-41d4-a716-446655440003', 2, 'A divine teacher and guide', true),
('550e8400-e29b-41d4-a716-446655440019', '550e8400-e29b-41d4-a716-446655440003', 3, 'A charioteer', false),
('550e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440003', 4, 'A king', false)
ON CONFLICT (id) DO NOTHING;

-- Quiz questions for Lesson 2
INSERT INTO public.quiz_questions (id, section_id, idx, stem, qtype, explanation) VALUES
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440202', 1, 'What is the main teaching of Sankhya Yoga?', 'MCQ_SINGLE', 'Sankhya Yoga teaches about the eternal nature of the soul and the importance of fulfilling one''s duty without attachment to results.'),
('550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440202', 2, 'True or False: The soul is eternal and indestructible.', 'TRUEFALSE', 'True. Krishna teaches that the soul is eternal, indestructible, and beyond the reach of weapons, fire, water, and wind.')
ON CONFLICT (id) DO NOTHING;

-- Quiz options for Lesson 2 questions
INSERT INTO public.quiz_options (id, question_id, idx, option_text, is_correct) VALUES
-- Question 1 options
('550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440021', 1, 'Physical exercise and meditation', false),
('550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440021', 2, 'The eternal nature of the soul and duty without attachment', true),
('550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440021', 3, 'Renunciation of all action', false),
('550e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440021', 4, 'Devotional worship', false),

-- Question 2 options
('550e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440022', 1, 'True', true),
('550e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440022', 2, 'False', false)
ON CONFLICT (id) DO NOTHING;

-- Quiz questions for Lesson 3
INSERT INTO public.quiz_questions (id, section_id, idx, stem, qtype, explanation) VALUES
('550e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440302', 1, 'What is Karma Yoga?', 'MCQ_SINGLE', 'Karma Yoga is the path of selfless action performed as a service to the divine, without attachment to results.'),
('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440302', 2, 'True or False: In Karma Yoga, one should avoid all action.', 'TRUEFALSE', 'False. Karma Yoga teaches that action is better than inaction, but action should be performed without attachment to results.')
ON CONFLICT (id) DO NOTHING;

-- Quiz options for Lesson 3 questions
INSERT INTO public.quiz_options (id, question_id, idx, option_text, is_correct) VALUES
-- Question 1 options
('550e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440029', 1, 'Avoiding all action', false),
('550e8400-e29b-41d4-a716-446655440032', '550e8400-e29b-41d4-a716-446655440029', 2, 'Selfless action without attachment to results', true),
('550e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440029', 3, 'Action for personal gain', false),
('550e8400-e29b-41d4-a716-446655440034', '550e8400-e29b-41d4-a716-446655440029', 4, 'Meditation only', false),

-- Question 2 options
('550e8400-e29b-41d4-a716-446655440035', '550e8400-e29b-41d4-a716-446655440030', 1, 'True', false),
('550e8400-e29b-41d4-a716-446655440036', '550e8400-e29b-41d4-a716-446655440030', 2, 'False', true)
ON CONFLICT (id) DO NOTHING;

-- Verify the data was inserted correctly
SELECT 
    c.title as course_title,
    COUNT(l.id) as lesson_count,
    COUNT(ls.id) as section_count,
    COUNT(qq.id) as question_count
FROM public.courses c
LEFT JOIN public.lessons l ON c.id = l.course_id
LEFT JOIN public.lesson_sections ls ON l.id = ls.lesson_id
LEFT JOIN public.quiz_questions qq ON ls.id = qq.section_id
GROUP BY c.id, c.title
ORDER BY c.title;
