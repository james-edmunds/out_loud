# Out Loud - Product Roadmap 🗺️

Based on expert feedback and current MVP status, here's our path to a polished, shippable macOS app.

## 🎯 Current Status: MVP Complete ✅
- ✅ Core functionality working
- ✅ OpenAI Whisper API integration
- ✅ Basic UI with results screen
- ✅ Achievement system
- ✅ Session persistence

---

## 🚀 Phase 1: UI Polish & UX (Week 1-2)
*Priority: High - Addresses visual hierarchy and usability issues*

### **Visual Hierarchy Fixes**
- [ ] **Two-tier layout**: Overall score block + compact sub-metrics grid
- [ ] **Reduce visual noise**: Consolidate cards, use 8pt spacing grid
- [ ] **Primary CTA**: Make "Practice Again" or "View Details" the clear next action
- [ ] **Max content width**: Constrain to 680-760pt for better readability

### **Color Semantics**
- [ ] **Reserve green** for "meets/exceeds target" only
- [ ] **Use neutral colors** for informational metrics
- [ ] **Context for orange**: Show targets inline "128 WPM (target 150±20)"
- [ ] **Status-based coloring**: Good/Warning/Neutral system

### **Copy Clarity**
- [ ] **Tighten headlines**: "Reading Results" with date/passage length
- [ ] **Clear button labels**: "View session details", "Practice again"
- [ ] **Remove fluff**: Replace "Here's how you did!" with specific info
- [ ] **Define metrics**: Tooltip for "Clarity" explaining confidence score

### **Typography & Numbers**
- [ ] **SF Pro font** with tabular numbers for metrics
- [ ] **Consistent type scale**: 28/20/16/14pt hierarchy
- [ ] **Proper leading** and spacing

### **Achievements Redesign**
- [ ] **Collapse to chips** or move to Details screen
- [ ] **Smarter badges**: "3 sessions in a row", "+20 WPM improvement"
- [ ] **Reduce visual competition** with main results

---

## 🎨 Phase 2: Platform Polish (Week 2-3)
*Priority: High - Essential for App Store submission*

### **macOS Integration**
- [ ] **Dark Mode support** with proper color schemes
- [ ] **Dynamic Type** support for accessibility
- [ ] **VoiceOver labels** on all metrics and controls
- [ ] **Window resize** handling and constraints

### **App Infrastructure**
- [ ] **App Sandbox** enablement with proper entitlements
- [ ] **App Icon** design and implementation (Light/Dark variants)
- [ ] **Accent color** definition
- [ ] **Privacy policy** creation (minimal, clear)

### **Performance & Reliability**
- [ ] **CPU monitoring** during transcription
- [ ] **Responsive UI** during processing
- [ ] **Intel + Apple Silicon** testing
- [ ] **Error handling** improvements

---

## 📊 Phase 3: Enhanced Details View (Week 3-4)
*Priority: Medium - Adds significant value*

### **Detailed Analytics**
- [ ] **Session metadata**: Date, time, duration, word count
- [ ] **WPM vs target** with visual range indicators
- [ ] **Error breakdown**: Substitutions, omissions, insertions
- [ ] **Timeline sparkline** of WPM throughout session (using Charts framework)

### **Advanced Features**
- [ ] **Transcript view** with inline error highlights
- [ ] **Target customization**: User-settable WPM goals
- [ ] **WCPM calculation**: Words Correct Per Minute
- [ ] **Session comparison** and progress tracking

---

## 🏪 Phase 4: App Store Preparation (Week 4-5)
*Priority: High - Required for distribution*

### **Legal & Compliance**
- [ ] **Name trademark check**: Verify "Out Loud" availability
- [ ] **App Privacy declarations**: Data collection transparency
- [ ] **Usage descriptions**: Microphone, network access explanations
- [ ] **Age rating** and target audience clarification

### **App Store Assets**
- [ ] **Product page copy** (no diagnostic claims)
- [ ] **Keywords** research and optimization
- [ ] **Screenshots** (Light & Dark mode, 1-3 key screens)
- [ ] **App description** focusing on practice/feedback

### **Technical Requirements**
- [ ] **Code signing** with Developer ID
- [ ] **Notarization** setup
- [ ] **TestFlight** internal testing
- [ ] **External beta** testing (5-10 users)

---

## 💰 Phase 5: Monetization Strategy (Week 5-6)
*Priority: Medium - Revenue model*

### **Freemium Model**
- [ ] **Free tier**: Live reading + basic results
- [ ] **Pro features**: Session history, exports (PDF/CSV), custom targets
- [ ] **Advanced analytics**: Per-word feedback, multiple voice playback
- [ ] **One-time purchase** or small subscription model

### **No Ads Policy**
- ✅ **Education-focused**: Avoid ads for better user experience
- ✅ **Privacy-first**: No cross-app tracking
- ✅ **Clean experience**: Focus on learning outcomes

---

## 🔮 Phase 6: Future Enhancements (Post-Launch)
*Priority: Low - Long-term vision*

### **Advanced Features**
- [ ] **On-device Whisper**: Privacy-first speech recognition
- [ ] **Multiple languages**: Expand beyond English
- [ ] **Reading passages**: Built-in content library
- [ ] **Progress analytics**: Long-term improvement tracking

### **Platform Expansion**
- [ ] **iOS companion**: Sync across devices
- [ ] **Web dashboard**: Progress tracking online
- [ ] **Educator tools**: Classroom management features

---

## 🎯 Immediate Next Steps (This Week)

### **High Impact, Low Effort**
1. **Fix visual hierarchy**: Two-tier layout implementation
2. **Clarify copy**: Remove fluff, add context
3. **Color semantics**: Reserve green for success only
4. **Primary CTA**: Make next action obvious

### **Technical Prep**
1. **App Sandbox**: Enable with proper entitlements
2. **Dark Mode**: Basic implementation
3. **Privacy policy**: Draft minimal version
4. **Performance**: Monitor CPU during transcription

---

## 📋 Decision Points

### **Architecture Decisions**
- **✅ Cloud Whisper**: Continue with OpenAI API (declare in privacy)
- **🤔 On-device option**: Consider for v2 (privacy advantage)
- **✅ Target audience**: Adults/teens (avoid children's app restrictions)
- **✅ Claims**: Practice/feedback only (no diagnostic language)

### **Distribution Strategy**
- **🎯 App Store**: Primary distribution channel
- **🤔 Direct download**: Consider as backup option
- **✅ TestFlight**: Use for beta testing

---

## 📊 Success Metrics

### **Pre-Launch**
- [ ] **UI polish score**: 8/10 visual hierarchy
- [ ] **Performance**: <2s processing time
- [ ] **Accessibility**: VoiceOver compatible
- [ ] **Beta feedback**: 4+ stars from testers

### **Post-Launch**
- [ ] **App Store rating**: 4+ stars
- [ ] **User retention**: 30% weekly active
- [ ] **Session completion**: 80%+ finish rate
- [ ] **Upgrade rate**: 10%+ to Pro features

---

## 🛠️ Implementation Notes

### **SwiftUI Patterns to Implement**
```swift
// Two-tier layout structure
VStack {
    OverallScoreCard()  // Primary focus
    CompactMetricsGrid() // Secondary info
    PrimaryCTA()        // Clear next action
}

// Status-based coloring
enum MetricStatus { case good, warning, neutral }

// Consistent spacing
let spacing = AppSpacing.grid8pt
```

### **Key Files to Update**
- `ResultsView.swift` - Main UI overhaul
- `Constants.swift` - Typography and spacing
- `Info.plist` - Privacy and permissions
- `Entitlements` - App Sandbox setup

---

**Next Review**: End of Week 1 (UI Polish completion)  
**Target Ship Date**: Week 5 (App Store submission)  
**Success Definition**: 4+ star rating, positive user feedback, sustainable usage