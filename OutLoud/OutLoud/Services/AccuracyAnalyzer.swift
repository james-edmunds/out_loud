import Foundation

protocol AccuracyAnalyzerProtocol {
    func compareTexts(original: String, spoken: String) -> AccuracyResult
    func identifyMispronunciations(_ comparison: AccuracyResult) -> [Mispronunciation]
    func calculateWPM(wordCount: Int, duration: TimeInterval) -> Double
}

struct AccuracyResult {
    let overallAccuracy: Double
    let wordLevelAccuracy: Double
    let completionRate: Double
    let addedWords: [String]
    let missedWords: [String]
    let totalWords: Int
    let spokenWords: Int
}

struct Mispronunciation {
    let originalWord: String
    let spokenWord: String
    let position: Int
}

class AccuracyAnalyzer: AccuracyAnalyzerProtocol {
    func compareTexts(original: String, spoken: String) -> AccuracyResult {
        let originalWords = preprocessText(original)
        let spokenWords = preprocessText(spoken)
        
        let totalWords = originalWords.count
        let spokenWordCount = spokenWords.count
        
        // Calculate completion rate
        let completionRate = min(Double(spokenWordCount) / Double(totalWords), 1.0)
        
        // Find added and missed words using word-level comparison
        let (addedWords, missedWords) = findWordDifferences(original: originalWords, spoken: spokenWords)
        
        // Calculate word-level accuracy
        let correctWords = totalWords - missedWords.count
        let wordLevelAccuracy = totalWords > 0 ? Double(correctWords) / Double(totalWords) : 0.0
        
        // Calculate overall accuracy (considering both missed words and added words)
        let totalErrors = missedWords.count + addedWords.count
        let overallAccuracy = max(0.0, 1.0 - (Double(totalErrors) / Double(max(totalWords, spokenWordCount))))
        
        return AccuracyResult(
            overallAccuracy: overallAccuracy,
            wordLevelAccuracy: wordLevelAccuracy,
            completionRate: completionRate,
            addedWords: addedWords,
            missedWords: missedWords,
            totalWords: totalWords,
            spokenWords: spokenWordCount
        )
    }
    
    func identifyMispronunciations(_ comparison: AccuracyResult) -> [Mispronunciation] {
        // For now, we'll identify mispronunciations as words that were missed
        // In a more sophisticated implementation, we could use phonetic matching
        var mispronunciations: [Mispronunciation] = []
        
        for (index, missedWord) in comparison.missedWords.enumerated() {
            // Try to find a similar word in the added words (potential mispronunciation)
            if let similarWord = findSimilarWord(missedWord, in: comparison.addedWords) {
                mispronunciations.append(Mispronunciation(
                    originalWord: missedWord,
                    spokenWord: similarWord,
                    position: index
                ))
            }
        }
        
        return mispronunciations
    }
    
    func calculateWPM(wordCount: Int, duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        let minutes = duration / 60.0
        return Double(wordCount) / minutes
    }
    
    // MARK: - Private Helper Methods
    
    private func preprocessText(_ text: String) -> [String] {
        return text
            .lowercased()
            .replacingOccurrences(of: "[^a-zA-Z0-9\\s]", with: "", options: .regularExpression)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
    
    private func findWordDifferences(original: [String], spoken: [String]) -> (added: [String], missed: [String]) {
        let originalSet = Set(original)
        let spokenSet = Set(spoken)
        
        // Find words that were added (in spoken but not in original)
        let addedWords = Array(spokenSet.subtracting(originalSet))
        
        // Find words that were missed (in original but not in spoken)
        let missedWords = Array(originalSet.subtracting(spokenSet))
        
        return (addedWords, missedWords)
    }
    
    private func findSimilarWord(_ target: String, in words: [String]) -> String? {
        var bestMatch: String?
        var bestScore = 0.0
        
        for word in words {
            let similarity = calculateStringSimilarity(target, word)
            if similarity > bestScore && similarity > 0.6 { // Threshold for similarity
                bestScore = similarity
                bestMatch = word
            }
        }
        
        return bestMatch
    }
    
    private func calculateStringSimilarity(_ str1: String, _ str2: String) -> Double {
        let distance = levenshteinDistance(str1, str2)
        let maxLength = max(str1.count, str2.count)
        
        guard maxLength > 0 else { return 1.0 }
        
        return 1.0 - (Double(distance) / Double(maxLength))
    }
    
    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let str1Array = Array(str1)
        let str2Array = Array(str2)
        let str1Count = str1Array.count
        let str2Count = str2Array.count
        
        if str1Count == 0 { return str2Count }
        if str2Count == 0 { return str1Count }
        
        var matrix = Array(repeating: Array(repeating: 0, count: str2Count + 1), count: str1Count + 1)
        
        // Initialize first row and column
        for i in 0...str1Count {
            matrix[i][0] = i
        }
        for j in 0...str2Count {
            matrix[0][j] = j
        }
        
        // Fill the matrix
        for i in 1...str1Count {
            for j in 1...str2Count {
                let cost = str1Array[i-1] == str2Array[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return matrix[str1Count][str2Count]
    }
}

// MARK: - WPM Analysis Extensions
extension AccuracyAnalyzer {
    
    enum WPMPerformance {
        case tooSlow
        case belowTarget
        case ideal
        case aboveTarget
        case tooFast
        
        var description: String {
            switch self {
            case .tooSlow:
                return "Too slow - try to read faster"
            case .belowTarget:
                return "Below target - good pace but could be faster"
            case .ideal:
                return "Perfect pace - ideal reading speed!"
            case .aboveTarget:
                return "Above target - good speed but watch clarity"
            case .tooFast:
                return "Too fast - slow down for better comprehension"
            }
        }
        
        var color: String {
            switch self {
            case .tooSlow, .tooFast:
                return "red"
            case .belowTarget, .aboveTarget:
                return "orange"
            case .ideal:
                return "green"
            }
        }
    }
    
    func evaluateWPMPerformance(_ wpm: Double) -> WPMPerformance {
        switch wpm {
        case 0..<100:
            return .tooSlow
        case 100..<150:
            return .belowTarget
        case 150...160:
            return .ideal
        case 160..<200:
            return .aboveTarget
        default:
            return .tooFast
        }
    }
    
    func getTargetWPMRange() -> ClosedRange<Double> {
        return 150.0...160.0
    }
    
    func getAcceptableWPMRange() -> ClosedRange<Double> {
        return 120.0...180.0
    }
    
    func calculateWPMScore(_ wpm: Double) -> Int {
        let performance = evaluateWPMPerformance(wpm)
        
        switch performance {
        case .ideal:
            return 100
        case .belowTarget:
            // Scale from 70-95 based on how close to ideal
            let progress = (wpm - 100) / (150 - 100) // 0 to 1
            return Int(70 + (progress * 25))
        case .aboveTarget:
            // Scale from 95-70 based on how far from ideal
            let excess = min(wpm - 160, 40) // Cap at 40 WPM over
            let penalty = (excess / 40) * 25 // 0 to 25 point penalty
            return Int(95 - penalty)
        case .tooSlow:
            // Scale from 10-70 based on how slow
            let progress = min(wpm / 100, 1.0) // 0 to 1
            return Int(10 + (progress * 60))
        case .tooFast:
            // Penalty for being too fast
            return max(10, 70 - Int((wpm - 200) / 10))
        }
    }
}