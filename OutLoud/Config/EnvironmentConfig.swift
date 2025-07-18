import Foundation

// Alternative approach using environment variables
class EnvironmentConfig {
    static let shared = EnvironmentConfig()
    
    private init() {}
    
    var openAIAPIKey: String {
        // Check environment variable first
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return envKey
        }
        
        // Fallback to config file
        return ConfigManager.shared.openAIAPIKey
    }
    
    // Usage: Set environment variable in Xcode scheme
    // Product -> Scheme -> Edit Scheme -> Run -> Environment Variables
    // Add: OPENAI_API_KEY = your_key_here
}