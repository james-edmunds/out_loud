# Out Loud 🎤

A native macOS reading practice app that gamifies oral reading through voice analysis and real-time feedback.

![Out Loud Results](https://img.shields.io/badge/Status-Working-brightgreen) ![macOS](https://img.shields.io/badge/Platform-macOS%2012.0+-blue) ![Swift](https://img.shields.io/badge/Language-Swift-orange) ![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)

## ✨ Features

### 📊 **Reading Analysis**
- **Accuracy Scoring** - Word-level comparison with detailed feedback
- **Reading Speed** - WPM calculation with target ranges (150-160 WPM ideal)
- **Completion Tracking** - Percentage of text actually read
- **Speech Clarity** - Confidence scores from advanced speech recognition

### 🎮 **Gamification**
- **Achievement System** - Unlock badges for performance milestones
- **Progress Tracking** - Session history and improvement trends  
- **Performance Scoring** - Overall scores combining accuracy, speed, and completion
- **Visual Feedback** - Beautiful progress circles and detailed metrics

### 🔧 **Technical Features**
- **High-Quality Speech Recognition** - OpenAI Whisper API integration
- **Native macOS Audio** - AVFoundation recording with proper permissions
- **Data Persistence** - Session history and progress tracking
- **Error Handling** - Comprehensive error management with recovery suggestions
- **Accessibility** - VoiceOver support and proper accessibility labels

## 🚀 Quick Start

### Prerequisites
- **macOS 12.0+** (Monterey or later)
- **Xcode 14.0+**
- **OpenAI API Key** ([Get one here](https://platform.openai.com/api-keys))

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd out_loud
   ```

2. **Open in Xcode**
   ```bash
   open OutLoud/OutLoud.xcodeproj
   ```

3. **Configure your API key**
   - In Xcode: Project → OutLoud Target → Info tab
   - Add key: `NSMicrophoneUsageDescription`
   - Value: `Out Loud needs microphone access to record your reading for analysis.`
   - Update `OutLoud/Config/Config.plist` with your OpenAI API key

4. **Build and Run**
   - Press `Cmd+R` or click the ▶️ play button
   - Grant microphone permission when prompted

## 🎯 How to Use

### 1. **Enter Text**
- Paste or type the text you want to practice reading
- Supports articles, book chapters, speeches, etc.
- Word and character count displayed

### 2. **Record Reading**
- Click the record button (blue circle)
- Read the text aloud clearly
- Click stop when finished (red square)

### 3. **View Results**
- **Overall Score** - Combined performance rating
- **Accuracy** - Percentage of words read correctly
- **Reading Speed** - Words per minute with target feedback
- **Completion** - Percentage of text completed
- **Achievements** - Badges for performance milestones

### 4. **Track Progress**
- Session history automatically saved
- Progress trends and statistics
- Achievement collection

## 📈 Scoring System

### **Accuracy Score**
- **100%** - Perfect reading, no errors
- **95%+** - Excellent, minimal errors
- **80%+** - Good, few mistakes
- **<80%** - Needs improvement

### **Reading Speed (WPM)**
- **150-160 WPM** - Ideal range (100 points)
- **120-180 WPM** - Acceptable range (70-95 points)
- **<120 WPM** - Too slow
- **>180 WPM** - May sacrifice clarity

### **Achievements**
- 🌟 **Word Perfect** - 95%+ accuracy
- ⚡ **Speed Reader** - Hit ideal reading speed
- 🏁 **Finisher** - Complete entire text
- 👑 **Reading Master** - 90%+ overall score
- 💎 **Perfectionist** - Perfect accuracy + completion
- 🔥 **Speed Demon** - Fast and accurate
- 👶 **First Steps** - Complete first session

## 🏗️ Architecture

### **Tech Stack**
- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Combine
- **Speech Recognition**: OpenAI Whisper API
- **Audio**: AVFoundation
- **Persistence**: UserDefaults + Core Data ready

### **Project Structure**
```
OutLoud/
├── Models/              # Data structures
│   ├── ReadingSession.swift
│   ├── ReadingMetrics.swift
│   └── GameScore.swift
├── Views/               # SwiftUI interfaces
│   ├── MainView.swift
│   ├── TextInputView.swift
│   ├── RecordingView.swift
│   └── ResultsView.swift
├── ViewModels/          # MVVM business logic
│   ├── MainViewModel.swift
│   ├── RecordingViewModel.swift
│   └── TextInputViewModel.swift
├── Services/            # Core functionality
│   ├── AudioRecordingService.swift
│   ├── WhisperAPIService.swift
│   ├── AccuracyAnalyzer.swift
│   ├── GameEngine.swift
│   └── PersistenceService.swift
├── Utilities/           # Helper functions
│   ├── TextValidator.swift
│   ├── ErrorHandler.swift
│   └── Constants.swift
└── Config/              # Configuration
    ├── ConfigManager.swift
    └── Config.plist
```

## 🧪 Testing

### **Run Tests**
```bash
# In Xcode
Cmd+U

# Or command line
xcodebuild test -project OutLoud.xcodeproj -scheme OutLoud
```

### **Test Coverage**
- ✅ Unit tests for all business logic
- ✅ Integration tests for complete user flows
- ✅ Mock services for external dependencies
- ✅ Error handling and edge cases

## 💰 API Costs

**OpenAI Whisper API Pricing:**
- **$0.006 per minute** of audio
- 2-minute session ≈ $0.012
- 100 sessions ≈ $1.20
- Very affordable for personal use

Monitor usage at [OpenAI Usage Dashboard](https://platform.openai.com/usage)

## 🔒 Privacy & Security

### **Data Handling**
- ✅ Audio recordings processed via OpenAI Whisper API
- ✅ Session data stored locally on device
- ✅ No personal data transmitted beyond audio for transcription
- ✅ API keys stored securely in configuration files

### **Permissions**
- **Microphone** - Required for audio recording
- **Network** - Required for speech recognition API calls

## 🛠️ Development

### **Adding Features**
1. Follow MVVM architecture patterns
2. Add unit tests for new functionality
3. Update integration tests for new user flows
4. Follow Swift naming conventions

### **Common Tasks**
```bash
# Clean build
Product → Clean Build Folder

# Reset simulator
Device → Erase All Content and Settings

# View logs
Window → Devices and Simulators → View Device Logs
```

## 🐛 Troubleshooting

### **Build Issues**
- **Clean build folder**: Product → Clean Build Folder
- **Restart Xcode** if needed
- **Check macOS version** (12.0+ required)

### **Runtime Issues**
- **Microphone permission**: System Preferences → Security & Privacy → Privacy → Microphone
- **API key errors**: Check Config.plist has valid OpenAI key
- **Network issues**: Verify internet connection for API calls

### **Performance Issues**
- **Long processing times**: Normal for first API call
- **Memory warnings**: Restart app if needed
- **Audio quality**: Use built-in microphone for best results

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI** - Whisper API for high-quality speech recognition
- **Apple** - SwiftUI and AVFoundation frameworks
- **Swift Community** - Inspiration and best practices

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/out-loud/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/out-loud/discussions)
- **Email**: your-email@example.com

---

**Built with ❤️ for better reading practice**

*Transform your reading practice into an engaging, measurable experience with immediate feedback and gamification elements.*