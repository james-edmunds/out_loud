import XCTest
@testable import OutLoud

class IntegrationTests: XCTestCase {
    var mainViewModel: MainViewModel!
    var mockAudioService: MockAudioRecordingService!
    var mockSpeechService: MockSpeechRecognitionService!
    var mockPersistenceService: MockPersistenceService!
    
    override func setUp() {
        super.setUp()
        
        mockAudioService = MockAudioRecordingService()
        mockSpeechService = MockSpeechRecognitionService()
        mockPersistenceService = MockPersistenceService()
        
        mainViewModel = MainViewModel(
            audioService: mockAudioService,
            speechService: mockSpeechService,
            persistenceService: mockPersistenceService
        )
    }
    
    override func tearDown() {
        mainViewModel = nil
        mockAudioService = nil
        mockSpeechService = nil
        mockPersistenceService = nil
        super.tearDown()
    }
    
    // MARK: - Complete User Flow Tests
    
    @MainActor
    func testCompleteSuccessfulFlow() async {
        // 1. Start with text input
        XCTAssertEqual(mainViewModel.appState, .textInput)
        
        // 2. Enter valid text
        mainViewModel.inputText = "This is a test reading passage for integration testing."
        
        // 3. Start recording
        mainViewModel.startRecording()
        XCTAssertEqual(mainViewModel.appState, .recording)
        
        // 4. Simulate recording completion
        let testURL = createTestAudioFile()
        mockSpeechService.mockTranscription = "This is a test reading passage for integration testing."
        mockSpeechService.mockConfidence = 0.95
        
        mainViewModel.processRecording(url: testURL)
        
        // Wait for async processing
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // 5. Verify results state
        XCTAssertEqual(mainViewModel.appState, .results)
        XCTAssertNotNil(mainViewModel.currentSession)
        
        // 6. Verify session was saved
        XCTAssertTrue(mockPersistenceService.saveSessionCalled)
        XCTAssertEqual(mockPersistenceService.savedSessions.count, 1)
        
        // 7. Verify session data
        let session = mainViewModel.currentSession!
        XCTAssertEqual(session.originalText, "This is a test reading passage for integration testing.")
        XCTAssertEqual(session.transcribedText, "This is a test reading passage for integration testing.")
        XCTAssertEqual(session.metrics.accuracy, 1.0, accuracy: 0.01)
        XCTAssertGreaterThan(session.score.overallScore, 80)
    }
    
    @MainActor
    func testFlowWithSpeechRecognitionError() async {
        // Setup
        mainViewModel.inputText = "Test text for error scenario"
        mainViewModel.startRecording()
        
        // Simulate speech recognition failure
        mockSpeechService.shouldThrowError = true
        mockSpeechService.errorToThrow = WhisperAPIError.networkError("Connection failed")
        
        let testURL = createTestAudioFile()
        mainViewModel.processRecording(url: testURL)
        
        // Wait for async processing
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify error state
        if case .error(let message) = mainViewModel.appState {
            XCTAssertTrue(message.contains("Connection failed"))
        } else {
            XCTFail("Expected error state")
        }
        
        // Verify no session was saved
        XCTAssertFalse(mockPersistenceService.saveSessionCalled)
    }
    
    @MainActor
    func testRetryFlow() async {
        // Start with error state
        mainViewModel.inputText = "Test text"
        mainViewModel.startRecording()
        
        // Cause an error
        mockSpeechService.shouldThrowError = true
        mockSpeechService.errorToThrow = WhisperAPIError.networkError("Network error")
        
        let testURL = createTestAudioFile()
        mainViewModel.processRecording(url: testURL)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify error state
        if case .error = mainViewModel.appState {
            // Now retry
            mockSpeechService.shouldThrowError = false
            mockSpeechService.mockTranscription = "Test text"
            
            mainViewModel.retryFromError()
            XCTAssertEqual(mainViewModel.appState, .recording)
            
            // Process recording again
            mainViewModel.processRecording(url: testURL)
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Should now succeed
            XCTAssertEqual(mainViewModel.appState, .results)
        } else {
            XCTFail("Expected error state initially")
        }
    }
    
    @MainActor
    func testNewSessionFlow() async {
        // Complete a session first
        mainViewModel.inputText = "First session text"
        mainViewModel.startRecording()
        
        mockSpeechService.mockTranscription = "First session text"
        let testURL = createTestAudioFile()
        mainViewModel.processRecording(url: testURL)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(mainViewModel.appState, .results)
        XCTAssertNotNil(mainViewModel.currentSession)
        
        // Start new session
        mainViewModel.startNewSession()
        
        // Verify reset state
        XCTAssertEqual(mainViewModel.appState, .textInput)
        XCTAssertEqual(mainViewModel.inputText, "")
        XCTAssertNil(mainViewModel.currentSession)
    }
    
    @MainActor
    func testInvalidTextHandling() {
        // Try to start recording with empty text
        mainViewModel.inputText = ""
        mainViewModel.startRecording()
        
        // Should remain in text input state and show alert
        XCTAssertEqual(mainViewModel.appState, .textInput)
        XCTAssertTrue(mainViewModel.showingAlert)
        XCTAssertTrue(mainViewModel.alertMessage.contains("valid text"))
    }
    
    @MainActor
    func testCancelRecordingFlow() {
        mainViewModel.inputText = "Test text for cancellation"
        mainViewModel.startRecording()
        
        XCTAssertEqual(mainViewModel.appState, .recording)
        
        // Cancel recording
        mainViewModel.cancelRecording()
        
        // Should return to text input
        XCTAssertEqual(mainViewModel.appState, .textInput)
        XCTAssertEqual(mainViewModel.inputText, "Test text for cancellation") // Text should be preserved
    }
    
    // MARK: - Data Persistence Integration Tests
    
    @MainActor
    func testSessionPersistenceIntegration() async {
        // Complete multiple sessions
        for i in 1...3 {
            mainViewModel.inputText = "Session \(i) text"
            mainViewModel.startRecording()
            
            mockSpeechService.mockTranscription = "Session \(i) text"
            let testURL = createTestAudioFile()
            mainViewModel.processRecording(url: testURL)
            
            try? await Task.sleep(nanoseconds: 50_000_000)
            
            XCTAssertEqual(mainViewModel.appState, .results)
            
            // Start new session for next iteration
            if i < 3 {
                mainViewModel.startNewSession()
            }
        }
        
        // Verify all sessions were saved
        XCTAssertEqual(mockPersistenceService.savedSessions.count, 3)
        
        // Verify session data
        let sessions = mockPersistenceService.savedSessions
        for (index, session) in sessions.enumerated() {
            XCTAssertTrue(session.originalText.contains("Session \(index + 1)"))
        }
    }
    
    @MainActor
    func testPersistenceErrorHandling() async {
        // Setup persistence to fail
        mockPersistenceService.shouldThrowError = true
        mockPersistenceService.errorToThrow = PersistenceError.saveFailed
        
        mainViewModel.inputText = "Test text"
        mainViewModel.startRecording()
        
        mockSpeechService.mockTranscription = "Test text"
        let testURL = createTestAudioFile()
        mainViewModel.processRecording(url: testURL)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should still reach results state (persistence errors don't block user flow)
        XCTAssertEqual(mainViewModel.appState, .results)
        XCTAssertNotNil(mainViewModel.currentSession)
        
        // But save should have been attempted
        XCTAssertTrue(mockPersistenceService.saveSessionCalled)
    }
    
    // MARK: - Error Recovery Integration Tests
    
    @MainActor
    func testMultipleErrorRecoveryAttempts() async {
        mainViewModel.inputText = "Test text for multiple errors"
        mainViewModel.startRecording()
        
        let testURL = createTestAudioFile()
        
        // First attempt - network error
        mockSpeechService.shouldThrowError = true
        mockSpeechService.errorToThrow = WhisperAPIError.networkError("Network error")
        
        mainViewModel.processRecording(url: testURL)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        if case .error = mainViewModel.appState {
            // Second attempt - API error
            mockSpeechService.errorToThrow = WhisperAPIError.apiError("API error")
            mainViewModel.retryFromError()
            mainViewModel.processRecording(url: testURL)
            try? await Task.sleep(nanoseconds: 50_000_000)
            
            if case .error = mainViewModel.appState {
                // Third attempt - success
                mockSpeechService.shouldThrowError = false
                mockSpeechService.mockTranscription = "Test text for multiple errors"
                
                mainViewModel.retryFromError()
                mainViewModel.processRecording(url: testURL)
                try? await Task.sleep(nanoseconds: 50_000_000)
                
                // Should finally succeed
                XCTAssertEqual(mainViewModel.appState, .results)
                XCTAssertNotNil(mainViewModel.currentSession)
            } else {
                XCTFail("Expected second error")
            }
        } else {
            XCTFail("Expected first error")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestAudioFile() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let audioURL = tempDir.appendingPathComponent("test_audio.m4a")
        
        // Create a dummy file
        let dummyData = Data("dummy audio data".utf8)
        try? dummyData.write(to: audioURL)
        
        return audioURL
    }
}

// MARK: - Mock Services

class MockAudioRecordingService: AudioRecordingServiceProtocol {
    var isRecording: Bool = false
    var shouldThrowError = false
    var errorToThrow: Error = AudioRecordingError.recordingFailed("Mock error")
    
    func requestMicrophonePermission() async -> Bool {
        return !shouldThrowError
    }
    
    func startRecording() async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        isRecording = true
    }
    
    func stopRecording() async -> URL? {
        isRecording = false
        return FileManager.default.temporaryDirectory.appendingPathComponent("mock_recording.m4a")
    }
    
    func getRecordingDuration() -> TimeInterval {
        return 30.0 // Mock 30 seconds
    }
}

class MockSpeechRecognitionService: SpeechRecognitionServiceProtocol {
    var mockTranscription = "Mock transcription"
    var mockConfidence: Float = 0.95
    var shouldThrowError = false
    var errorToThrow: Error = WhisperAPIError.networkError("Mock error")
    
    func transcribeAudio(from url: URL) async throws -> String {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockTranscription
    }
    
    func getConfidenceScore() -> Float {
        return mockConfidence
    }
}

class MockPersistenceService: PersistenceServiceProtocol {
    var savedSessions: [ReadingSession] = []
    var saveSessionCalled = false
    var shouldThrowError = false
    var errorToThrow: Error = PersistenceError.saveFailed
    
    func saveSession(_ session: ReadingSession) throws {
        saveSessionCalled = true
        if shouldThrowError {
            throw errorToThrow
        }
        savedSessions.append(session)
    }
    
    func loadSessions() throws -> [ReadingSession] {
        if shouldThrowError {
            throw errorToThrow
        }
        return savedSessions
    }
    
    func deleteSession(withId id: UUID) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        savedSessions.removeAll { $0.id == id }
    }
    
    func getSessionCount() -> Int {
        return savedSessions.count
    }
    
    func getAverageScore() -> Double {
        guard !savedSessions.isEmpty else { return 0.0 }
        let total = savedSessions.reduce(0) { $0 + $1.score.overallScore }
        return Double(total) / Double(savedSessions.count)
    }
    
    func getBestScore() -> Int {
        return savedSessions.map { $0.score.overallScore }.max() ?? 0
    }
}