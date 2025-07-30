import Foundation
import Combine

@MainActor
class RecordingViewModel: ObservableObject {
    @Published var recordingState: RecordingState = .ready
    @Published var recordingDuration: TimeInterval = 0
    @Published var recordingURL: URL?
    
    private let audioService: AudioRecordingServiceProtocol
    private var durationTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(audioService: AudioRecordingServiceProtocol = AudioRecordingService()) {
        self.audioService = audioService
    }
    
    func startRecording() async {
        do {
            recordingState = .processing
            try await audioService.startRecording()
            recordingState = .recording
            startDurationTimer()
        } catch {
            let errorMessage = ErrorHandler.userFriendlyMessage(for: error)
            recordingState = .error(errorMessage)
        }
    }
    
    func stopRecording() async {
        guard recordingState == .recording else { return }
        
        recordingState = .processing
        stopDurationTimer()
        
        if let url = await audioService.stopRecording() {
            recordingURL = url
            recordingState = .ready
        } else {
            recordingState = .error("Failed to save recording")
        }
    }
    
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration = self?.audioService.getRecordingDuration() ?? 0
            }
        }
    }
    
    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
        recordingDuration = 0
    }
    
    deinit {
        // Clean up timer synchronously
        durationTimer?.invalidate()
        durationTimer = nil
    }
}