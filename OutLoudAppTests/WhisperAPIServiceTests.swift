import XCTest
@testable import OutLoud

class WhisperAPIServiceTests: XCTestCase {
    var whisperService: WhisperAPIService!
    
    override func setUp() {
        super.setUp()
        whisperService = WhisperAPIService()
    }
    
    override func tearDown() {
        whisperService = nil
        super.tearDown()
    }
    
    func testConfigureAPIKey() {
        let testKey = "test-api-key"
        whisperService.configureAPIKey(testKey)
        
        // We can't directly test the private apiKey property,
        // but we can test that it doesn't throw the noAPIKey error
        // This would be better tested with a mock or by making apiKey internal
    }
    
    func testEstimateCost() {
        let duration: TimeInterval = 120 // 2 minutes
        let cost = whisperService.estimateCost(duration: duration)
        
        XCTAssertEqual(cost, 0.012, accuracy: 0.001) // 2 minutes * $0.006/minute
    }
    
    func testEstimateCost_ZeroDuration() {
        let cost = whisperService.estimateCost(duration: 0)
        XCTAssertEqual(cost, 0.0)
    }
    
    func testEstimateCost_OneMinute() {
        let duration: TimeInterval = 60 // 1 minute
        let cost = whisperService.estimateCost(duration: duration)
        
        XCTAssertEqual(cost, 0.006, accuracy: 0.001)
    }
    
    func testTranscribeAudio_NoAPIKey_ThrowsError() async {
        // Create a temporary file URL for testing
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.m4a")
        
        do {
            _ = try await whisperService.transcribeAudio(fileURL: tempURL)
            XCTFail("Expected WhisperAPIError.noAPIKey to be thrown")
        } catch WhisperAPIError.noAPIKey {
            // Expected error
        } catch {
            XCTFail("Expected WhisperAPIError.noAPIKey, got \(error)")
        }
    }
    
    // Note: Testing actual API calls would require a real API key and network access
    // These would be better suited for integration tests
}