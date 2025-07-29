import Foundation

struct GameScore: Codable {
    let overallScore: Int
    let accuracyScore: Int
    let speedScore: Int
    let completionScore: Int
    let achievements: [Achievement]
    
    init(overallScore: Int = 0, accuracyScore: Int = 0, speedScore: Int = 0, completionScore: Int = 0, achievements: [Achievement] = []) {
        self.overallScore = overallScore
        self.accuracyScore = accuracyScore
        self.speedScore = speedScore
        self.completionScore = completionScore
        self.achievements = achievements
    }
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let unlockedAt: Date
    
    init(name: String, description: String, iconName: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.iconName = iconName
        self.unlockedAt = Date()
    }
}