import Foundation

protocol SpeechRecognitionServiceProtocol {
    func transcribeAudio(from url: URL) async throws -> String
    func getConfidenceScore() -> Float
}

class SpeechRecognitionService: SpeechRecognitionServiceProtocol {
    private let whisperService: WhisperAPIServiceProtocol
    private var lastConfidenceScore: Float = 0.0
    
    init(whisperService: WhisperAPIServiceProtocol) {
        self.whisperService = whisperService
    }
    
    func transcribeAudio(from url: URL) async throws -> String {
        let response = try await whisperService.transcribeAudio(fileURL: url)
        lastConfidenceScore = response.confidence
        return response.text
    }
    
    func getConfidenceScore() -> Float {
        return lastConfidenceScore
    }
}

struct WhisperResponse {
    let text: String
    let confidence: Float
    
    init(text: String, confidence: Float = 0.95) {
        self.text = text
        self.confidence = confidence
    }
}