# Setting Up Xcode with File References

## The Right Way: Use References, Not Copies

### Why References Are Better:
- ✅ Edit in Xcode → changes your original files
- ✅ Edit in VS Code → changes appear in Xcode  
- ✅ Git sees all changes
- ✅ No duplicate files
- ✅ Everything stays in sync

### Step-by-Step Setup:

1. **Remove any copied files** (if you already added them):
   - Select files in Xcode navigator
   - Right-click → Delete → "Remove References"

2. **Add files as references**:
   - Right-click OutLoud folder in Xcode
   - "Add Files to 'OutLoud'"
   - Navigate to your project folder
   - Select all folders (Models, Services, ViewModels, etc.)
   - **IMPORTANT**: UNCHECK "Copy items if needed" ❌
   - Check "Create groups" ✅
   - Check "Add to target: OutLoud" ✅
   - Click "Add"

3. **Verify setup**:
   - Files should appear in Xcode navigator
   - Edit a file in Xcode
   - Check that the original file in your project folder was modified

### File Structure You Should See:

```
Xcode Navigator:
📱 OutLoud
├── 📁 OutLoud
│   ├── OutLoudApp.swift
│   ├── 📁 Views (folder reference)
│   ├── 📁 ViewModels (folder reference)  
│   ├── 📁 Services (folder reference)
│   ├── 📁 Models (folder reference)
│   ├── 📁 Utilities (folder reference)
│   ├── 📁 Config (folder reference)
│   └── OutLoud.entitlements
```

### How to Tell if You're Using References:
- Folder icons look slightly different (blue folders = references)
- When you edit in Xcode, original files change
- File paths in File Inspector show original location

### Development Workflow:
1. **Edit in Xcode** → Original files change
2. **Edit in VS Code** → Changes appear in Xcode
3. **Git commit** → All changes included
4. **No manual syncing needed** ✅