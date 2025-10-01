#!/bin/bash

# Dharma App Environment Variables Setup Script
# This script helps you set up environment variables for your Xcode project

echo "🚀 Setting up environment variables for Dharma app..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ Created .env file. Please edit it with your actual values."
else
    echo "✅ .env file already exists."
fi

echo ""
echo "📋 Next steps:"
echo "1. Edit the .env file with your actual API keys and configuration"
echo "2. In Xcode, go to your target's Build Settings"
echo "3. Add the following User-Defined settings:"
echo "   - SUPABASE_URL: \$(SUPABASE_URL)"
echo "   - SUPABASE_ANON_KEY: \$(SUPABASE_ANON_KEY)"
echo "   - OPENAI_API_KEY: \$(OPENAI_API_KEY)"
echo "   - GOOGLE_CLIENT_ID: \$(GOOGLE_CLIENT_ID)"
echo "   - GOOGLE_URL_SCHEME: \$(GOOGLE_URL_SCHEME)"
echo ""
echo "4. Add a Run Script Phase to your target with:"
echo "   source \${SRCROOT}/.env"
echo "   export SUPABASE_URL SUPABASE_ANON_KEY OPENAI_API_KEY GOOGLE_CLIENT_ID"
echo "   export GOOGLE_URL_SCHEME=\$(echo \$GOOGLE_CLIENT_ID | sed 's/\([^-]*\)-\([^.]*\)\.apps\.googleusercontent\.com/com.googleusercontent.apps.\1-\2/')"
echo ""
echo "🔒 Security reminder:"
echo "- Never commit the .env file to version control"
echo "- Add .env to your .gitignore file"
echo "- Use different keys for development and production"
echo ""
echo "✨ Setup complete! Your app will now use environment variables for configuration."
