-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.chat_conversations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  message_count integer DEFAULT 0,
  CONSTRAINT chat_conversations_pkey PRIMARY KEY (id),
  CONSTRAINT chat_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.chat_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid,
  content text NOT NULL,
  is_user boolean NOT NULL,
  timestamp timestamp with time zone DEFAULT now(),
  CONSTRAINT chat_messages_pkey PRIMARY KEY (id),
  CONSTRAINT chat_messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.chat_conversations(id)
);
CREATE TABLE public.courses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  course_order smallint NOT NULL,
  access boolean NOT NULL DEFAULT false,
  CONSTRAINT courses_pkey PRIMARY KEY (id)
);
CREATE TABLE public.daily_usage (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  date date NOT NULL,
  session_count integer DEFAULT 1,
  total_time_seconds integer DEFAULT 0,
  last_active_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT daily_usage_pkey PRIMARY KEY (id),
  CONSTRAINT daily_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.lesson_completions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  lesson_id uuid NOT NULL,
  attempt_number integer NOT NULL DEFAULT 1,
  score integer NOT NULL,
  total_questions integer NOT NULL,
  score_percentage numeric NOT NULL,
  time_elapsed_seconds integer NOT NULL,
  questions_answered jsonb,
  started_at timestamp with time zone NOT NULL,
  completed_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT lesson_completions_pkey PRIMARY KEY (id),
  CONSTRAINT lesson_completions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT lesson_completions_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id)
);
CREATE TABLE public.lesson_sections (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL,
  kind text NOT NULL CHECK (kind = ANY (ARRAY['SUMMARY'::text, 'QUIZ'::text, 'FINAL_THOUGHTS'::text, 'CLOSING_PRAYER'::text, 'REPORT'::text])),
  order_idx integer NOT NULL,
  content jsonb,
  CONSTRAINT lesson_sections_pkey PRIMARY KEY (id),
  CONSTRAINT lesson_sections_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id)
);
CREATE TABLE public.lessons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  order_idx integer NOT NULL,
  title text NOT NULL,
  subtitle text,
  image_url text,
  CONSTRAINT lessons_pkey PRIMARY KEY (id),
  CONSTRAINT lessons_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id)
);
CREATE TABLE public.user_lesson_progress (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  lesson_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'NOT_STARTED'::text,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  last_seen_at timestamp with time zone DEFAULT now(),
  last_score_pct numeric,
  best_score_pct numeric,
  total_completions integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_lesson_progress_pkey PRIMARY KEY (id),
  CONSTRAINT user_lesson_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT user_lesson_progress_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id)
);
CREATE TABLE public.user_lesson_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  lesson_id uuid NOT NULL,
  started_at timestamp with time zone NOT NULL,
  completed_at timestamp with time zone,
  duration_seconds integer,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_lesson_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT user_lesson_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT user_lesson_sessions_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id)
);
CREATE TABLE public.user_login_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  login_timestamp timestamp with time zone NOT NULL DEFAULT now(),
  session_duration_seconds integer,
  device_model text,
  device_os text,
  app_version text,
  location_country text,
  location_city text,
  location_coordinates point,
  auth_method text,
  ip_address text,
  is_first_login boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_login_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT user_login_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_stats (
  user_id uuid NOT NULL,
  xp_total integer NOT NULL DEFAULT 0,
  streak_count integer NOT NULL DEFAULT 0,
  longest_streak integer NOT NULL DEFAULT 0,
  last_active_date date,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_stats_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email USER-DEFINED NOT NULL UNIQUE,
  password_hash text NOT NULL,
  display_name text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  status text NOT NULL DEFAULT 'active'::text,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE TABLE public.xp_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  lesson_id uuid,
  rule_code text NOT NULL,
  awarded_xp integer NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT xp_events_pkey PRIMARY KEY (id),
  CONSTRAINT xp_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT xp_events_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id),
  CONSTRAINT xp_events_rule_code_fkey FOREIGN KEY (rule_code) REFERENCES public.xp_rules(code)
);
CREATE TABLE public.xp_rules (
  code text NOT NULL,
  xp_amount integer NOT NULL,
  CONSTRAINT xp_rules_pkey PRIMARY KEY (code)
);