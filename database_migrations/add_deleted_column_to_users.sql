-- Add deleted column to users table
-- This migration adds a boolean column to track if a user account has been deleted
-- When deleted = true, the user should not be able to log back in

ALTER TABLE users 
ADD COLUMN deleted BOOLEAN DEFAULT FALSE;

-- Add an index for better performance when filtering by deleted status
CREATE INDEX idx_users_deleted ON users(deleted);

-- Update any existing users to have deleted = false (they should be active by default)
UPDATE users SET deleted = FALSE WHERE deleted IS NULL;

-- Add a comment to document the column
COMMENT ON COLUMN users.deleted IS 'Indicates if the user account has been deleted. When true, user cannot log in.';
