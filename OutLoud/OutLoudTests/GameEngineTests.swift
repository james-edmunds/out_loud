import XCTest
@testable import OutLoud

class GameEngineTests: XCTestCase {
    var gameEngine: GameEngine!
    
    override func setUp() {
        super.setUp()
        gameEngine = GameEngine()
    }
    
    override func tearDown() {
        gameEngine = nil
        super.tearDown()
    }
    
    // MARK: - Overall Score Calculation Tests
    
    func testCalculateOverallScore_PerfectPerformance() {
        let metrics = ReadingMetrics(
            accuracy: 1.0,
            wpm: 155, // Ideal speed
            duration: 60,
            wordCount: 155,
            completionRate: 1.0,
            confidenceScore: 0.95,
            addedWords: [],
            missedWords: []
        )
        
        let score = gameEngine.calculateOverallScore(metrics)
        
        XCTAssertEqual(score.accuracyScore, 100)
        XCTAssertEqual(score.speedScore, 100)
        XCTAssertEqual(score.completionScore, 100)
        XCTAssertEqual(score.overallScore, 100)
        XCTAssertFalse(score.achievements.isEmpty)
    }
    
    func testCalculateOverallScore_AveragePerformance() {
        let metrics = ReadingMetrics(
            accuracy: 0.85,
            wpm: 130, // Below target but acceptable
            duration: 60,
            wordCount: 130,
            completionRate: 0.9,
            confidenceScore: 0.8,
            addedWords: ["um"],
            missedWords: ["the", "quick"]
        )
        
        let score = gameEngine.calculateOverallScore(metrics)
        
        XCTAssertEqual(score.accuracyScore, 85)
        XCTAssertGreaterThan(score.speedScore, 70)
        XCTAssertLessThan(score.speedScore, 100)
        XCTAssertEqual(score.completionScore, 90)
        XCTAssertGreaterThan(score.overallScore, 70)
        XCTAssertLessThan(score.overallScore, 100)
    }
    
    func testCalculateOverallScore_PoorPerformance() {
        let metrics = ReadingMetrics(
            accuracy: 0.6,
            wpm: 80, // Too slow
            duration: 90,
            wordCount: 120,
            completionRate: 0.5,
            confidenceScore: 0.6,
            addedWords: ["um", "uh", "like"],
            missedWords: ["many", "words", "missed"]
        )
        
        let score = gameEngine.calculateOverallScore(metrics)
        
        XCTAssertEqual(score.accuracyScore, 60)
        XCTAssertLessThan(score.speedScore, 70)
        XCTAssertEqual(score.completionScore, 50)
        XCTAssertLessThan(score.overallScore, 70)
    }
    
    // MARK: - Achievement Tests
    
    func testCheckAchievements_WordPerfect() {
        let score = GameScore(
            overallScore: 95,
            accuracyScore: 96,
            speedScore: 90,
            completionScore: 100,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        let wordPerfect = achievements.first { $0.name == "Word Perfect" }
        XCTAssertNotNil(wordPerfect)
        XCTAssertEqual(wordPerfect?.description, "Achieved 95%+ accuracy")
    }
    
    func testCheckAchievements_SpeedReader() {
        let score = GameScore(
            overallScore: 90,
            accuracyScore: 85,
            speedScore: 95,
            completionScore: 90,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        let speedReader = achievements.first { $0.name == "Speed Reader" }
        XCTAssertNotNil(speedReader)
        XCTAssertEqual(speedReader?.iconName, "bolt.fill")
    }
    
    func testCheckAchievements_Finisher() {
        let score = GameScore(
            overallScore: 85,
            accuracyScore: 80,
            speedScore: 85,
            completionScore: 100,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        let finisher = achievements.first { $0.name == "Finisher" }
        XCTAssertNotNil(finisher)
        XCTAssertEqual(finisher?.description, "Read the entire text")
    }
    
    func testCheckAchievements_ReadingMaster() {
        let score = GameScore(
            overallScore: 92,
            accuracyScore: 90,
            speedScore: 95,
            completionScore: 90,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        let readingMaster = achievements.first { $0.name == "Reading Master" }
        XCTAssertNotNil(readingMaster)
        XCTAssertEqual(readingMaster?.iconName, "crown.fill")
    }
    
    func testCheckAchievements_WellRounded() {
        let score = GameScore(
            overallScore: 85,
            accuracyScore: 85,
            speedScore: 85,
            completionScore: 85,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        let wellRounded = achievements.first { $0.name == "Well Rounded" }
        XCTAssertNotNil(wellRounded)
        XCTAssertEqual(wellRounded?.description, "Good performance in all areas")
    }
    
    func testCheckAchievements_Perfectionist() {
        let score = GameScore(
            overallScore: 100,
            accuracyScore: 100,
            speedScore: 95,
            completionScore: 100,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        let perfectionist = achievements.first { $0.name == "Perfectionist" }
        XCTAssertNotNil(perfectionist)
        XCTAssertEqual(perfectionist?.iconName, "diamond.fill")
    }
    
    func testCheckAchievements_SpeedDemon() {
        let score = GameScore(
            overallScore: 90,
            accuracyScore: 90,
            speedScore: 95,
            completionScore: 85,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        let speedDemon = achievements.first { $0.name == "Speed Demon" }
        XCTAssertNotNil(speedDemon)
        XCTAssertEqual(speedDemon?.description, "Fast and accurate reading")
    }
    
    func testCheckAchievements_FirstSteps() {
        let score = GameScore(
            overallScore: 50,
            accuracyScore: 50,
            speedScore: 50,
            completionScore: 50,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        // First Steps should always be awarded
        let firstSteps = achievements.first { $0.name == "First Steps" }
        XCTAssertNotNil(firstSteps)
        XCTAssertEqual(firstSteps?.description, "Completed your first reading session")
    }
    
    func testCheckAchievements_MultipleAchievements() {
        let score = GameScore(
            overallScore: 95,
            accuracyScore: 100,
            speedScore: 95,
            completionScore: 100,
            achievements: []
        )
        
        let achievements = gameEngine.checkAchievements(score)
        
        // Should get multiple achievements
        XCTAssertGreaterThan(achievements.count, 3)
        
        let achievementNames = achievements.map { $0.name }
        XCTAssertTrue(achievementNames.contains("Word Perfect"))
        XCTAssertTrue(achievementNames.contains("Speed Reader"))
        XCTAssertTrue(achievementNames.contains("Finisher"))
        XCTAssertTrue(achievementNames.contains("Reading Master"))
        XCTAssertTrue(achievementNames.contains("Perfectionist"))
        XCTAssertTrue(achievementNames.contains("Speed Demon"))
        XCTAssertTrue(achievementNames.contains("First Steps"))
    }
    
    // MARK: - Edge Cases
    
    func testCalculateOverallScore_ZeroMetrics() {
        let metrics = ReadingMetrics()
        
        let score = gameEngine.calculateOverallScore(metrics)
        
        XCTAssertEqual(score.accuracyScore, 0)
        XCTAssertGreaterThanOrEqual(score.speedScore, 0)
        XCTAssertEqual(score.completionScore, 0)
        XCTAssertGreaterThanOrEqual(score.overallScore, 0)
    }
}