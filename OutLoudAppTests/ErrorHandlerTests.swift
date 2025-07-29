import XCTest
@testable import OutLoud

class ErrorHandlerTests: XCTestCase {
    
    func testHandleAudioRecordingError() {
        let audioError = AudioRecordingError.permissionDenied
        let handledError = ErrorHandler.handle(audioError)
        
        if case .audioRecording(let error) = handledError {
            XCTAssertEqual(error, AudioRecordingError.permissionDenied)
        } else {
            XCTFail("Expected audioRecording error")
        }
    }
    
    func testHandleWhisperAPIError() {
        let whisperError = WhisperAPIError.noAPIKey
        let handledError = ErrorHandler.handle(whisperError)
        
        if case .speechRecognition(let error) = handledError {
            XCTAssertEqual(error, WhisperAPIError.noAPIKey)
        } else {
            XCTFail("Expected speechRecognition error")
        }
    }
    
    func testHandlePersistenceError() {
        let persistenceError = PersistenceError.saveFailed
        let handledError = ErrorHandler.handle(persistenceError)
        
        if case .persistence(let error) = handledError {
            XCTAssertEqual(error, PersistenceError.saveFailed)
        } else {
            XCTFail("Expected persistence error")
        }
    }
    
    func testHandleURLError() {
        let urlError = URLError(.notConnectedToInternet)
        let handledError = ErrorHandler.handle(urlError)
        
        if case .networkError(let message) = handledError {
            XCTAssertEqual(message, "No internet connection")
        } else {
            XCTFail("Expected networkError")
        }
    }
    
    func testHandleUnknownError() {
        struct CustomError: Error {
            let message = "Custom error message"
        }
        
        let customError = CustomError()
        let handledError = ErrorHandler.handle(customError)
        
        if case .unknownError = handledError {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected unknownError")
        }
    }
    
    func testUserFriendlyMessage() {
        let audioError = AudioRecordingError.permissionDenied
        let message = ErrorHandler.userFriendlyMessage(for: audioError)
        
        XCTAssertTrue(message.contains("permission"))
        XCTAssertTrue(message.contains("microphone"))
    }
    
    func testRecoverySuggestion() {
        let audioError = AudioRecordingError.permissionDenied
        let suggestion = ErrorHandler.recoverySuggestion(for: audioError)
        
        XCTAssertNotNil(suggestion)
        XCTAssertTrue(suggestion!.contains("System Preferences"))
    }
    
    func testCanRetry() {
        let permissionError = AudioRecordingError.permissionDenied
        let networkError = WhisperAPIError.networkError("Connection failed")
        
        XCTAssertFalse(ErrorHandler.canRetry(permissionError))
        XCTAssertTrue(ErrorHandler.canRetry(networkError))
    }
    
    // MARK: - OutLoudError Tests
    
    func testOutLoudErrorDescription() {
        let textError = OutLoudError.textValidation("Text too short")
        XCTAssertEqual(textError.errorDescription, "Text validation error: Text too short")
        
        let networkError = OutLoudError.networkError("Connection timeout")
        XCTAssertEqual(networkError.errorDescription, "Network error: Connection timeout")
        
        let unknownError = OutLoudError.unknownError("Something went wrong")
        XCTAssertEqual(unknownError.errorDescription, "An unexpected error occurred: Something went wrong")
    }
    
    func testOutLoudErrorRecoverySuggestion() {
        let permissionError = OutLoudError.audioRecording(.permissionDenied)
        XCTAssertTrue(permissionError.recoverySuggestion!.contains("System Preferences"))
        
        let apiKeyError = OutLoudError.speechRecognition(.noAPIKey)
        XCTAssertTrue(apiKeyError.recoverySuggestion!.contains("API key"))
        
        let networkError = OutLoudError.networkError("Connection failed")
        XCTAssertTrue(networkError.recoverySuggestion!.contains("internet connection"))
    }
    
    func testOutLoudErrorIsRetryable() {
        let permissionError = OutLoudError.audioRecording(.permissionDenied)
        XCTAssertFalse(permissionError.isRetryable)
        
        let apiKeyError = OutLoudError.speechRecognition(.noAPIKey)
        XCTAssertFalse(apiKeyError.isRetryable)
        
        let textError = OutLoudError.textValidation("Invalid text")
        XCTAssertFalse(textError.isRetryable)
        
        let networkError = OutLoudError.networkError("Connection failed")
        XCTAssertTrue(networkError.isRetryable)
        
        let recordingError = OutLoudError.audioRecording(.recordingFailed("Device busy"))
        XCTAssertTrue(recordingError.isRetryable)
    }
    
    func testSpecificURLErrorHandling() {
        let timeoutError = URLError(.timedOut)
        let handledError = ErrorHandler.handle(timeoutError)
        
        if case .networkError(let message) = handledError {
            XCTAssertEqual(message, "Request timed out")
        } else {
            XCTFail("Expected networkError with timeout message")
        }
        
        let hostError = URLError(.cannotFindHost)
        let handledHostError = ErrorHandler.handle(hostError)
        
        if case .networkError(let message) = handledHostError {
            XCTAssertEqual(message, "Cannot connect to server")
        } else {
            XCTFail("Expected networkError with host message")
        }
    }
}