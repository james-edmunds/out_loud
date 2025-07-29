import Foundation

struct ReadingMetrics: Codable {
    let accuracy: Double
    let wpm: Double
    let duration: TimeInterval
    let wordCount: Int
    let completionRate: Double
    let confidenceScore: Double
    let addedWords: [String]
    let missedWords: [String]
    
    init(accuracy: Double = 0.0, wpm: Double = 0.0, duration: TimeInterval = 0.0, wordCount: Int = 0, completionRate: Double = 0.0, confidenceScore: Double = 0.0, addedWords: [String] = [], missedWords: [String] = []) {
        self.accuracy = accuracy
        self.wpm = wpm
        self.duration = duration
        self.wordCount = wordCount
        self.completionRate = completionRate
        self.confidenceScore = confidenceScore
        self.addedWords = addedWords
        self.missedWords = missedWords
    }
}