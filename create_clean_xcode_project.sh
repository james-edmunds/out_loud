#!/bin/bash

echo "🧹 Cleaning up duplicate folders and creating fresh Xcode project..."

# Step 1: Clean up duplicate folders
echo "1. Removing duplicate folders..."
rm -rf "OutLoud/Config 2"
rm -rf "OutLoud/Models 2" 
rm -rf "OutLoud/Services 2"
rm -rf "OutLoud/Utilities 2"
rm -rf "OutLoud/ViewModels 2"
rm -rf "OutLoud/Views 2"

echo "✅ Removed duplicate folders"

# Step 2: Remove old Xcode project
echo "2. Removing old Xcode project..."
rm -rf OutLoud.xcodeproj

echo "✅ Removed old Xcode project"

# Step 3: List what we have now
echo "3. Current clean structure:"
echo "📁 OutLoud/"
ls -la OutLoud/ | grep "^d" | awk '{print "   📁 " $9}'
echo "📄 Swift files:"
find OutLoud -name "*.swift" | head -5
echo "   ... and more"

echo ""
echo "🎯 Next steps:"
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. macOS → App → SwiftUI"
echo "4. Name: OutLoud"
echo "5. Save in: $(pwd)"
echo "6. When created, drag OutLoud folder into Xcode navigator"
echo "7. Choose 'Reference files in place'"
echo ""
echo "This will give you a clean, proper setup! 🚀"