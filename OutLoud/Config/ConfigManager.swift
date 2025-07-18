import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    
    private var config: [String: Any] = [:]
    
    private init() {
        loadConfig()
    }
    
    private func loadConfig() {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ Config.plist not found. Using default values.")
            return
        }
        
        config = plist
    }
    
    // MARK: - API Configuration
    
    var openAIAPIKey: String {
        return config["OpenAI_API_Key"] as? String ?? ""
    }
    
    var apiBaseURL: String {
        return config["API_Base_URL"] as? String ?? "https://api.openai.com/v1"
    }
    
    var maxRecordingDuration: TimeInterval {
        return TimeInterval(config["Max_Recording_Duration"] as? Int ?? 300)
    }
    
    // MARK: - Validation
    
    var isConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_API_KEY_HERE"
    }
    
    func validateConfiguration() throws {
        guard isConfigured else {
            throw ConfigError.missingAPIKey
        }
        
        guard openAIAPIKey.hasPrefix("sk-") else {
            throw ConfigError.invalidAPIKey
        }
    }
}

enum ConfigError: Error, LocalizedError {
    case missingAPIKey
    case invalidAPIKey
    case configFileNotFound
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Please add your API key to Config.plist"
        case .invalidAPIKey:
            return "OpenAI API key format is invalid. It should start with 'sk-'"
        case .configFileNotFound:
            return "Configuration file not found"
        }
    }
}