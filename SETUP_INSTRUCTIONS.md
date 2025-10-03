# Dharma App Setup Instructions

## Required Dependencies

To complete the Google Sign-In setup, you need to add the following Swift Package Manager dependencies to your Xcode project:

### 1. Add Supabase Swift SDK
1. Open your project in Xcode
2. Go to File → Add Package Dependencies
3. Enter this URL: `https://github.com/supabase/supabase-swift`
4. Click "Add Package"
5. Select "Supabase" and "GoogleSignIn" when prompted

### 2. Add Google Sign-In SDK
1. Go to File → Add Package Dependencies
2. Enter this URL: `https://github.com/google/GoogleSignIn-iOS`
3. Click "Add Package"
4. Select "GoogleSignIn" when prompted

## Google Cloud Setup

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Google Sign-In API

### 2. Configure OAuth 2.0
1. Go to "Credentials" in the Google Cloud Console
2. Click "Create Credentials" → "OAuth 2.0 Client IDs"
3. Select "iOS" as application type
4. Add your app's bundle identifier (found in your Xcode project settings)
5. Download the `GoogleService-Info.plist` file

### 3. Add GoogleService-Info.plist to Xcode
1. Drag the downloaded `GoogleService-Info.plist` file into your Xcode project
2. Make sure "Copy items if needed" is checked
3. Make sure your app target is selected
4. Click "Finish"

### 4. Configure Supabase
1. Go to your Supabase project dashboard
2. Navigate to Authentication → Providers
3. Enable Google provider
4. Add your Google OAuth client ID and client secret
5. Set the redirect URL to: `https://your-project.supabase.co/auth/v1/callback`

## App Configuration

### 1. Add URL Scheme
1. In Xcode, select your project
2. Go to your app target → Info tab
3. Expand "URL Types"
4. Click the "+" button
5. Add a new URL scheme with your Google client ID (reversed):
   - Example: If your client ID is `123456789-abcdefg.apps.googleusercontent.com`
   - Add URL scheme: `com.googleusercontent.apps.123456789-abcdefg`

### 2. Add Google Logo Asset
1. Download the Google logo from [Google Branding Guidelines](https://developers.google.com/identity/branding-guidelines)
2. Add it to your `Assets.xcassets` as "google_logo"

## Testing
1. Build and run your app
2. The sign-in screen should appear first
3. Tap "Continue with Google" to test the authentication flow
4. After successful sign-in, you should see the onboarding flow (if not completed) or the main app

## Troubleshooting
- Make sure all dependencies are properly added
- Verify the GoogleService-Info.plist is in your project
- Check that the URL scheme is correctly configured
- Ensure Supabase Google provider is properly configured
- Check Xcode console for any error messages
