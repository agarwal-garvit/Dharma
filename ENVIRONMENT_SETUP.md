# Environment Variables Setup Guide

This guide will help you set up environment variables for all API keys and sensitive configuration in your Dharma app.

## 🔑 Keys That Need Environment Variables

1. **Supabase Configuration**
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous key

2. **OpenAI Configuration**
   - `OPENAI_API_KEY`: Your OpenAI API key for chat functionality

3. **Google Sign-In Configuration**
   - `GOOGLE_CLIENT_ID`: Your Google OAuth client ID

## 📋 Setup Steps

### Step 1: Create Environment File

1. Copy the example environment file:
   ```bash
   cp env.example .env
   ```

2. Edit the `.env` file with your actual values:
   ```bash
   # Supabase Configuration
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   
   # OpenAI Configuration
   OPENAI_API_KEY=your_openai_api_key_here
   
   # Google Sign-In Configuration
   GOOGLE_CLIENT_ID=your_google_client_id_here
   ```

### Step 2: Configure Xcode Build Settings

1. Open your project in Xcode
2. Select your target (Dharma)
3. Go to **Build Settings** tab
4. Click the **+** button and select **Add User-Defined Setting**
5. Add the following settings:

   | Setting Name | Value |
   |--------------|-------|
   | `SUPABASE_URL` | `$(SUPABASE_URL)` |
   | `SUPABASE_ANON_KEY` | `$(SUPABASE_ANON_KEY)` |
   | `OPENAI_API_KEY` | `$(OPENAI_API_KEY)` |
   | `GOOGLE_CLIENT_ID` | `$(GOOGLE_CLIENT_ID)` |
   | `GOOGLE_URL_SCHEME` | `$(GOOGLE_URL_SCHEME)` |

### Step 3: Add Run Script Phase

1. In Xcode, select your target
2. Go to **Build Phases** tab
3. Click the **+** button and select **New Run Script Phase**
4. Add this script:

   ```bash
   # Load environment variables
   if [ -f "${SRCROOT}/.env" ]; then
       source "${SRCROOT}/.env"
   fi
   
   # Export variables for build
   export SUPABASE_URL
   export SUPABASE_ANON_KEY
   export OPENAI_API_KEY
   export GOOGLE_CLIENT_ID
   
   # Generate Google URL scheme from client ID
   if [ -n "$GOOGLE_CLIENT_ID" ]; then
       GOOGLE_URL_SCHEME=$(echo $GOOGLE_CLIENT_ID | sed 's/\([^-]*\)-\([^.]*\)\.apps\.googleusercontent\.com/com.googleusercontent.apps.\1-\2/')
       export GOOGLE_URL_SCHEME
   fi
   ```

5. Make sure this script runs **before** the "Compile Sources" phase

### Step 4: Update .gitignore

Add the following to your `.gitignore` file:

```gitignore
# Environment variables
.env
.env.local
.env.*.local

# Xcode user data
*.xcuserstate
*.xcuserdatad/
```

## 🔧 Alternative: Using Xcode Scheme Environment Variables

If you prefer not to use a Run Script Phase, you can set environment variables directly in your Xcode scheme:

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** in the left sidebar
3. Go to the **Arguments** tab
4. Under **Environment Variables**, add:

   | Name | Value |
   |------|-------|
   | `SUPABASE_URL` | `https://your-project.supabase.co` |
   | `SUPABASE_ANON_KEY` | `your_supabase_anon_key` |
   | `OPENAI_API_KEY` | `your_openai_api_key` |
   | `GOOGLE_CLIENT_ID` | `your_google_client_id` |
   | `GOOGLE_URL_SCHEME` | `com.googleusercontent.apps.your-client-id` |

## 🧪 Testing the Setup

1. Build and run your app
2. Check the console for configuration status (if debug logging is enabled)
3. Test the following features:
   - User authentication (Google Sign-In)
   - Chat functionality
   - Database operations

## 🔒 Security Best Practices

1. **Never commit sensitive keys** to version control
2. **Use different keys** for development and production
3. **Rotate keys regularly** for security
4. **Use environment-specific configurations**
5. **Consider using a secrets management service** for production

## 🚨 Troubleshooting

### Common Issues:

1. **"Configuration validation failed"**
   - Check that all environment variables are set correctly
   - Verify the `.env` file exists and has the right format

2. **"SUPABASE_URL not found"**
   - Make sure the Run Script Phase is running before compilation
   - Check that the environment variable is exported correctly

3. **Google Sign-In not working**
   - Verify the `GOOGLE_CLIENT_ID` is correct
   - Check that the URL scheme is properly generated

4. **OpenAI API errors**
   - Verify your API key is valid and has sufficient credits
   - Check that the key has the correct permissions

### Debug Mode:

To enable debug logging, add this to your app's initialization:

```swift
#if DEBUG
Config.printConfigurationStatus()
#endif
```

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)
- [Xcode Build Settings Guide](https://developer.apple.com/documentation/xcode/build-settings-reference)

## ✅ Verification Checklist

- [ ] `.env` file created with actual values
- [ ] Xcode Build Settings configured
- [ ] Run Script Phase added (or scheme environment variables set)
- [ ] `.gitignore` updated
- [ ] App builds successfully
- [ ] Authentication works
- [ ] Chat functionality works
- [ ] No sensitive keys in version control

Your Dharma app is now properly configured with environment variables! 🎉
