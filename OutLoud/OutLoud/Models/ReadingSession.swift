import Foundation

struct ReadingSession: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let recordingURL: URL?
    let transcribedText: String
    let metrics: ReadingMetrics
    let score: GameScore
    let timestamp: Date
    
    init(originalText: String, recordingURL: URL? = nil, transcribedText: String = "", metrics: ReadingMetrics = ReadingMetrics(), score: GameScore = GameScore()) {
        self.id = UUID()
        self.originalText = originalText
        self.recordingURL = recordingURL
        self.transcribedText = transcribedText
        self.metrics = metrics
        self.score = score
        self.timestamp = Date()
    }
}