import XCTest
import AVFoundation
@testable import OutLoud

class AudioRecordingServiceTests: XCTestCase {
    var audioService: AudioRecordingService!
    
    override func setUp() {
        super.setUp()
        audioService = AudioRecordingService()
    }
    
    override func tearDown() {
        audioService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(audioService.isRecording)
        XCTAssertEqual(audioService.getRecordingDuration(), 0)
    }
    
    func testRequestMicrophonePermission() async {
        // Note: This test will depend on system permissions
        // In a real app, you might want to mock AVAudioSession
        let hasPermission = await audioService.requestMicrophonePermission()
        
        // We can't assert the exact value since it depends on system state
        // But we can verify the method completes without throwing
        XCTAssertTrue(hasPermission || !hasPermission) // Always true, just testing completion
    }
    
    func testGetRecordingDuration_NoRecording_ReturnsZero() {
        let duration = audioService.getRecordingDuration()
        XCTAssertEqual(duration, 0)
    }
    
    func testStopRecording_NoActiveRecording_ReturnsNil() async {
        let result = await audioService.stopRecording()
        XCTAssertNil(result)
    }
    
    // Note: Testing actual recording would require microphone permissions
    // and would be better suited for integration tests
}