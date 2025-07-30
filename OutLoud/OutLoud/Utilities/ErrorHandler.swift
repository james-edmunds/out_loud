import Foundation

enum OutLoudError: Error, LocalizedError {
    case audioRecording(AudioRecordingError)
    case speechRecognition(WhisperAPIError)
    case persistence(PersistenceError)
    case textValidation(String)
    case networkError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .audioRecording(let error):
            return error.errorDescription
        case .speechRecognition(let error):
            return error.errorDescription
        case .persistence(let error):
            return error.errorDescription
        case .textValidation(let message):
            return "Text validation error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknownError(let message):
            return "An unexpected error occurred: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .audioRecording(.permissionDenied):
            return "Please enable microphone access in System Preferences > Security & Privacy > Privacy > Microphone"
        case .audioRecording(.recordingFailed):
            return "Try checking your microphone connection and try again"
        case .audioRecording(.noActiveRecording):
            return "Start a new recording session"
        case .audioRecording(.fileSystemError):
            return "Check available storage space and try again"
        case .speechRecognition(.noAPIKey):
            return "Please configure your OpenAI API key in the app settings"
        case .speechRecognition(.networkError):
            return "Check your internet connection and try again"
        case .speechRecognition(.apiError):
            return "There may be an issue with the speech recognition service. Please try again later"
        case .speechRecognition(.invalidURL):
            return "There's a configuration issue. Please restart the app"
        case .speechRecognition(.invalidResponse):
            return "The speech recognition service returned an unexpected response. Please try again"
        case .persistence:
            return "Try restarting the app. Your data should be preserved"
        case .textValidation:
            return "Please check your text input and try again"
        case .networkError:
            return "Check your internet connection and try again"
        case .unknownError:
            return "Please try again. If the problem persists, restart the app"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .audioRecording(.permissionDenied):
            return false
        case .audioRecording(.recordingFailed), .audioRecording(.noActiveRecording), .audioRecording(.fileSystemError):
            return true
        case .speechRecognition(.noAPIKey):
            return false
        case .speechRecognition(.networkError), .speechRecognition(.apiError), .speechRecognition(.invalidURL), .speechRecognition(.invalidResponse):
            return true
        case .persistence:
            return true
        case .textValidation:
            return false
        case .networkError:
            return true
        case .unknownError:
            return true
        }
    }
}

class ErrorHandler {
    static func handle(_ error: Error) -> OutLoudError {
        if let outLoudError = error as? OutLoudError {
            return outLoudError
        }
        
        if let audioError = error as? AudioRecordingError {
            return .audioRecording(audioError)
        }
        
        if let whisperError = error as? WhisperAPIError {
            return .speechRecognition(whisperError)
        }
        
        if let persistenceError = error as? PersistenceError {
            return .persistence(persistenceError)
        }
        
        // Handle URLError (network errors)
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError("No internet connection")
            case .timedOut:
                return .networkError("Request timed out")
            case .cannotFindHost, .cannotConnectToHost:
                return .networkError("Cannot connect to server")
            default:
                return .networkError(urlError.localizedDescription)
            }
        }
        
        return .unknownError(error.localizedDescription)
    }
    
    static func userFriendlyMessage(for error: Error) -> String {
        let outLoudError = handle(error)
        return outLoudError.errorDescription ?? "An unexpected error occurred"
    }
    
    static func recoverySuggestion(for error: Error) -> String? {
        let outLoudError = handle(error)
        return outLoudError.recoverySuggestion
    }
    
    static func canRetry(_ error: Error) -> Bool {
        let outLoudError = handle(error)
        return outLoudError.isRetryable
    }
}