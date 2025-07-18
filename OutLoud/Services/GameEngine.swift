import Foundation

protocol GameEngineProtocol {
    func calculateOverallScore(_ metrics: ReadingMetrics) -> GameScore
    func checkAchievements(_ score: GameScore) -> [Achievement]
    func updateProgress(_ session: ReadingSession)
}

class GameEngine: GameEngineProtocol {
    // Target WPM ranges for scoring
    private let idealWPMRange = 150.0...160.0
    private let acceptableWPMRange = 120.0...180.0
    
    func calculateOverallScore(_ metrics: ReadingMetrics) -> GameScore {
        let accuracyScore = calculateAccuracyScore(metrics.accuracy)
        let speedScore = calculateSpeedScore(metrics.wpm)
        let completionScore = calculateCompletionScore(metrics.completionRate)
        
        let overallScore = Int((Double(accuracyScore + speedScore + completionScore) / 3.0).rounded())
        
        let gameScore = GameScore(
            overallScore: overallScore,
            accuracyScore: accuracyScore,
            speedScore: speedScore,
            completionScore: completionScore,
            achievements: []
        )
        
        // Check for achievements and create final score with achievements
        let achievements = checkAchievements(gameScore)
        
        return GameScore(
            overallScore: overallScore,
            accuracyScore: accuracyScore,
            speedScore: speedScore,
            completionScore: completionScore,
            achievements: achievements
        )
    }
    
    func checkAchievements(_ score: GameScore) -> [Achievement] {
        var achievements: [Achievement] = []
        
        // Perfect accuracy achievement
        if score.accuracyScore >= 95 {
            achievements.append(Achievement(
                name: "Word Perfect",
                description: "Achieved 95%+ accuracy",
                iconName: "star.fill"
            ))
        }
        
        // Speed achievements
        if score.speedScore >= 95 {
            achievements.append(Achievement(
                name: "Speed Reader",
                description: "Hit the ideal reading speed",
                iconName: "bolt.fill"
            ))
        }
        
        // Completion achievement
        if score.completionScore == 100 {
            achievements.append(Achievement(
                name: "Finisher",
                description: "Read the entire text",
                iconName: "checkmark.circle.fill"
            ))
        }
        
        // Overall excellence
        if score.overallScore >= 90 {
            achievements.append(Achievement(
                name: "Reading Master",
                description: "Excellent overall performance",
                iconName: "crown.fill"
            ))
        }
        
        // Consistency achievement (good in all areas)
        if score.accuracyScore >= 80 && score.speedScore >= 80 && score.completionScore >= 80 {
            achievements.append(Achievement(
                name: "Well Rounded",
                description: "Good performance in all areas",
                iconName: "circle.hexagongrid.fill"
            ))
        }
        
        // First attempt achievement
        achievements.append(Achievement(
            name: "First Steps",
            description: "Completed your first reading session",
            iconName: "figure.walk"
        ))
        
        // Perfectionist achievement
        if score.accuracyScore == 100 && score.completionScore == 100 {
            achievements.append(Achievement(
                name: "Perfectionist",
                description: "Perfect accuracy and completion",
                iconName: "diamond.fill"
            ))
        }
        
        // Speed demon (very fast but still accurate)
        if score.speedScore >= 90 && score.accuracyScore >= 85 {
            achievements.append(Achievement(
                name: "Speed Demon",
                description: "Fast and accurate reading",
                iconName: "flame.fill"
            ))
        }
        
        return achievements
    }
    
    func updateProgress(_ session: ReadingSession) {
        // Implementation for progress tracking will be added when we implement persistence
    }
    
    // MARK: - Private Scoring Methods
    
    private func calculateAccuracyScore(_ accuracy: Double) -> Int {
        return Int((accuracy * 100).rounded())
    }
    
    private func calculateSpeedScore(_ wpm: Double) -> Int {
        if idealWPMRange.contains(wpm) {
            return 100
        } else if acceptableWPMRange.contains(wpm) {
            // Scale based on distance from ideal range
            let distanceFromIdeal = min(
                abs(wpm - idealWPMRange.lowerBound),
                abs(wpm - idealWPMRange.upperBound)
            )
            let maxDistance = max(
                idealWPMRange.lowerBound - acceptableWPMRange.lowerBound,
                acceptableWPMRange.upperBound - idealWPMRange.upperBound
            )
            let score = 100 - Int((distanceFromIdeal / maxDistance) * 30)
            return max(score, 70)
        } else {
            // Below acceptable range
            if wpm < acceptableWPMRange.lowerBound {
                return max(Int((wpm / acceptableWPMRange.lowerBound) * 70), 10)
            } else {
                // Above acceptable range
                return max(Int((acceptableWPMRange.upperBound / wpm) * 70), 10)
            }
        }
    }
    
    private func calculateCompletionScore(_ completionRate: Double) -> Int {
        return Int((completionRate * 100).rounded())
    }
}