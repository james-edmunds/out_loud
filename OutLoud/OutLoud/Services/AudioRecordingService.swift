import Foundation
import AVFoundation

protocol AudioRecordingServiceProtocol {
    func requestMicrophonePermission() async -> Bool
    func startRecording() async throws
    func stopRecording() async -> URL?
    func getRecordingDuration() -> TimeInterval
    var isRecording: Bool { get }
}

enum AudioRecordingError: Error, LocalizedError {
    case permissionDenied
    case recordingFailed(String)
    case noActiveRecording
    case fileSystemError
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission is required to record audio. Please enable it in System Preferences."
        case .recordingFailed(let message):
            return "Recording failed: \(message)"
        case .noActiveRecording:
            return "No active recording to stop."
        case .fileSystemError:
            return "Unable to save recording file."
        }
    }
}

class AudioRecordingService: NSObject, AudioRecordingServiceProtocol {
    private var audioRecorder: AVAudioRecorder?
    private var recordingStartTime: Date?
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    func requestMicrophonePermission() async -> Bool {
        // On macOS, we check the authorization status
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func startRecording() async throws {
        // Check permission first
        let hasPermission = await requestMicrophonePermission()
        guard hasPermission else {
            throw AudioRecordingError.permissionDenied
        }
        
        // Create recording URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        // Configure recording settings for macOS
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            
            guard audioRecorder?.record() == true else {
                throw AudioRecordingError.recordingFailed("Failed to start recording")
            }
            
            recordingStartTime = Date()
        } catch {
            throw AudioRecordingError.recordingFailed(error.localizedDescription)
        }
    }
    
    func stopRecording() async -> URL? {
        guard let recorder = audioRecorder, recorder.isRecording else {
            return nil
        }
        
        recorder.stop()
        
        let recordingURL = recorder.url
        audioRecorder = nil
        recordingStartTime = nil
        
        return recordingURL
    }
    
    func getRecordingDuration() -> TimeInterval {
        guard let startTime = recordingStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio recording encode error: \(error.localizedDescription)")
        }
    }
}