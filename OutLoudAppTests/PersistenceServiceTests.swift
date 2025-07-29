import XCTest
@testable import OutLoud

class PersistenceServiceTests: XCTestCase {
    var persistenceService: PersistenceService!
    let testKey = "OutLoud.ReadingSessions.Test"
    
    override func setUp() {
        super.setUp()
        persistenceService = PersistenceService()
        
        // Clear any existing test data
        UserDefaults.standard.removeObject(forKey: testKey)
        UserDefaults.standard.removeObject(forKey: "OutLoud.ReadingSessions")
    }
    
    override func tearDown() {
        // Clean up test data
        UserDefaults.standard.removeObject(forKey: testKey)
        UserDefaults.standard.removeObject(forKey: "OutLoud.ReadingSessions")
        persistenceService = nil
        super.tearDown()
    }
    
    func testSaveAndLoadSession() throws {
        let session = createTestSession()
        
        // Save session
        try persistenceService.saveSession(session)
        
        // Load sessions
        let loadedSessions = try persistenceService.loadSessions()
        
        XCTAssertEqual(loadedSessions.count, 1)
        XCTAssertEqual(loadedSessions.first?.id, session.id)
        XCTAssertEqual(loadedSessions.first?.originalText, session.originalText)
        XCTAssertEqual(loadedSessions.first?.score.overallScore, session.score.overallScore)
    }
    
    func testLoadEmptySessions() throws {
        let sessions = try persistenceService.loadSessions()
        XCTAssertTrue(sessions.isEmpty)
    }
    
    func testSaveMultipleSessions() throws {
        let session1 = createTestSession(text: "First session")
        let session2 = createTestSession(text: "Second session")
        
        try persistenceService.saveSession(session1)
        try persistenceService.saveSession(session2)
        
        let loadedSessions = try persistenceService.loadSessions()
        
        XCTAssertEqual(loadedSessions.count, 2)
        
        // Should be sorted by timestamp (newest first)
        XCTAssertTrue(loadedSessions[0].timestamp >= loadedSessions[1].timestamp)
    }
    
    func testDeleteSession() throws {
        let session1 = createTestSession(text: "First session")
        let session2 = createTestSession(text: "Second session")
        
        try persistenceService.saveSession(session1)
        try persistenceService.saveSession(session2)
        
        // Delete first session
        try persistenceService.deleteSession(withId: session1.id)
        
        let loadedSessions = try persistenceService.loadSessions()
        
        XCTAssertEqual(loadedSessions.count, 1)
        XCTAssertEqual(loadedSessions.first?.id, session2.id)
    }
    
    func testGetSessionCount() throws {
        XCTAssertEqual(persistenceService.getSessionCount(), 0)
        
        try persistenceService.saveSession(createTestSession())
        XCTAssertEqual(persistenceService.getSessionCount(), 1)
        
        try persistenceService.saveSession(createTestSession())
        XCTAssertEqual(persistenceService.getSessionCount(), 2)
    }
    
    func testGetAverageScore() throws {
        XCTAssertEqual(persistenceService.getAverageScore(), 0.0)
        
        let session1 = createTestSession(overallScore: 80)
        let session2 = createTestSession(overallScore: 90)
        
        try persistenceService.saveSession(session1)
        try persistenceService.saveSession(session2)
        
        XCTAssertEqual(persistenceService.getAverageScore(), 85.0)
    }
    
    func testGetBestScore() throws {
        XCTAssertEqual(persistenceService.getBestScore(), 0)
        
        let session1 = createTestSession(overallScore: 80)
        let session2 = createTestSession(overallScore: 95)
        let session3 = createTestSession(overallScore: 70)
        
        try persistenceService.saveSession(session1)
        try persistenceService.saveSession(session2)
        try persistenceService.saveSession(session3)
        
        XCTAssertEqual(persistenceService.getBestScore(), 95)
    }
    
    func testGetProgressStats() throws {
        let stats = persistenceService.getProgressStats()
        
        XCTAssertEqual(stats.totalSessions, 0)
        XCTAssertEqual(stats.averageScore, 0.0)
        XCTAssertEqual(stats.bestScore, 0)
        
        // Add some sessions
        try persistenceService.saveSession(createTestSession(overallScore: 80, accuracy: 0.9, wpm: 150))
        try persistenceService.saveSession(createTestSession(overallScore: 85, accuracy: 0.85, wpm: 160))
        
        let updatedStats = persistenceService.getProgressStats()
        
        XCTAssertEqual(updatedStats.totalSessions, 2)
        XCTAssertEqual(updatedStats.averageScore, 82.5)
        XCTAssertEqual(updatedStats.bestScore, 85)
        XCTAssertEqual(updatedStats.averageAccuracy, 0.875, accuracy: 0.001)
        XCTAssertEqual(updatedStats.averageWPM, 155.0)
    }
    
    func testSessionLimit() throws {
        // Add more than 100 sessions
        for i in 1...105 {
            let session = createTestSession(text: "Session \(i)", overallScore: i % 100)
            try persistenceService.saveSession(session)
        }
        
        let sessions = try persistenceService.loadSessions()
        
        // Should be limited to 100 sessions
        XCTAssertEqual(sessions.count, 100)
    }
    
    func testGetRecentSessions() throws {
        // Add 15 sessions
        for i in 1...15 {
            let session = createTestSession(text: "Session \(i)")
            try persistenceService.saveSession(session)
        }
        
        let recentSessions = try persistenceService.getRecentSessions(limit: 10)
        
        XCTAssertEqual(recentSessions.count, 10)
        
        // Should be the most recent ones
        XCTAssertTrue(recentSessions.allSatisfy { session in
            session.originalText.contains("Session")
        })
    }
    
    // MARK: - Helper Methods
    
    private func createTestSession(
        text: String = "Test reading text",
        overallScore: Int = 85,
        accuracy: Double = 0.9,
        wpm: Double = 150
    ) -> ReadingSession {
        let metrics = ReadingMetrics(
            accuracy: accuracy,
            wpm: wpm,
            duration: 60,
            wordCount: 25,
            completionRate: 1.0,
            confidenceScore: 0.95,
            addedWords: [],
            missedWords: []
        )
        
        let score = GameScore(
            overallScore: overallScore,
            accuracyScore: Int(accuracy * 100),
            speedScore: 90,
            completionScore: 100,
            achievements: []
        )
        
        return ReadingSession(
            originalText: text,
            transcribedText: text,
            metrics: metrics,
            score: score
        )
    }
}