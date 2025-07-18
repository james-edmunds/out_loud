# Out Loud - Setup Guide

## Prerequisites

1. **macOS 12.0+** (Monterey or later)
2. **Xcode 14.0+** (from Mac App Store)
3. **OpenAI API Key** (from https://platform.openai.com/api-keys)

## Quick Setup

### 1. Clone and Configure

```bash
git clone <your-repo-url>
cd out_loud
```

### 2. Add Your API Key

**Option A: Configuration File (Recommended)**
1. Open `OutLoud/Config/Config.plist`
2. Replace `YOUR_API_KEY_HERE` with your actual OpenAI API key
3. Save the file

**Option B: Environment Variable**
1. In Xcode: Product → Scheme → Edit Scheme
2. Go to Run → Environment Variables
3. Add: `OPENAI_API_KEY` = `your_api_key_here`

### 3. Build and Run

```bash
# Open in Xcode
open OutLoud.xcodeproj

# Or build from command line
xcodebuild -project OutLoud.xcodeproj -scheme OutLoud build
```

## Security Best Practices

### ✅ What We Do Right
- API keys stored in separate config files
- Config files are gitignored
- Runtime validation of API keys
- Environment variable support

### ⚠️ For Production Apps
- Use **Keychain Services** for sensitive data
- Implement **server-side proxy** for API calls
- Use **App Store Connect** for configuration
- Enable **App Transport Security**

## Configuration Options

Edit `Config.plist` to customize:

```xml
<key>OpenAI_API_Key</key>
<string>sk-your-key-here</string>

<key>Max_Recording_Duration</key>
<integer>300</integer> <!-- 5 minutes -->

<key>API_Base_URL</key>
<string>https://api.openai.com/v1</string>
```

## Troubleshooting

### "API Key Missing" Error
- Check that `Config.plist` has your real API key
- Ensure the key starts with `sk-`
- Verify the file is included in the Xcode project

### Microphone Permission Denied
- Go to System Preferences → Security & Privacy → Privacy → Microphone
- Enable access for "OutLoud"

### Build Errors
- Make sure you're using Xcode 14.0+
- Clean build folder: Product → Clean Build Folder
- Restart Xcode if needed

## Development

### Project Structure
```
OutLoud/
├── Models/          # Data structures
├── Views/           # SwiftUI views
├── ViewModels/      # MVVM view models
├── Services/        # Business logic
├── Config/          # Configuration management
└── Utilities/       # Helper functions

OutLoudTests/        # Unit and integration tests
```

### Adding Features
1. Follow MVVM architecture
2. Add unit tests for new services
3. Update integration tests for new flows
4. Follow Swift naming conventions

## API Costs

OpenAI Whisper API pricing:
- **$0.006 per minute** of audio
- A 2-minute reading session costs ~$0.012
- 100 sessions ≈ $1.20

Monitor usage at https://platform.openai.com/usage