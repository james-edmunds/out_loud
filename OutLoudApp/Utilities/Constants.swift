import SwiftUI

struct AppConstants {
    // MARK: - UI Constants
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let standardPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    
    // MARK: - Animation Constants
    static let standardAnimation = Animation.easeInOut(duration: 0.3)
    static let quickAnimation = Animation.easeInOut(duration: 0.2)
    static let slowAnimation = Animation.easeInOut(duration: 0.5)
    
    // MARK: - Color Scheme
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let background = Color(NSColor.controlBackgroundColor)
        static let cardBackground = Color(NSColor.controlBackgroundColor)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let headline = Font.headline.weight(.medium)
        static let body = Font.body
        static let caption = Font.caption
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let minimumTapTarget: CGFloat = 44
        static let reducedMotionScale: CGFloat = 0.8
    }
    
    // MARK: - Performance
    struct Performance {
        static let maxTextLength = 10000
        static let maxSessionHistory = 100
        static let debounceDelay: TimeInterval = 0.3
    }
}

// MARK: - View Extensions for Consistency
extension View {
    func standardCard() -> some View {
        self
            .padding(AppConstants.standardPadding)
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(AppConstants.cornerRadius)
    }
    
    func standardButton() -> some View {
        self
            .frame(minHeight: AppConstants.Accessibility.minimumTapTarget)
            .animation(AppConstants.quickAnimation, value: true)
    }
    
    func accessibleTapTarget() -> some View {
        self
            .frame(minWidth: AppConstants.Accessibility.minimumTapTarget,
                   minHeight: AppConstants.Accessibility.minimumTapTarget)
    }
}