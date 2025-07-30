import Foundation
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var appState: AppState = .textInput
    @Published var inputText: String = ""
    @Published var currentSession: ReadingSession?
    @Published var showingAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let audioService: AudioRecordingServiceProtocol
    private let speechService: SpeechRecognitionServiceProtocol
    private let accuracyAnalyzer: AccuracyAnalyzerProtocol
    private let gameEngine: GameEngineProtocol
    private let persistenceService: PersistenceServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var recordingStartTime: Date?
    
    init(
        audioService: AudioRecordingServiceProtocol = AudioRecordingService(),
        speechService: SpeechRecognitionServiceProtocol? = nil,
        accuracyAnalyzer: AccuracyAnalyzerProtocol = AccuracyAnalyzer(),
        gameEngine: GameEngineProtocol = GameEngine(),
        persistenceService: PersistenceServiceProtocol = PersistenceService()
    ) {
        self.audioService = audioService
        self.accuracyAnalyzer = accuracyAnalyzer
        self.gameEngine = gameEngine
        self.persistenceService = persistenceService
        
        // Initialize speech service with Whisper API
        let whisperService = WhisperAPIService()
        
        // Configure API key from secure config
        do {
            try ConfigManager.shared.validateConfiguration()
            whisperService.configureAPIKey(ConfigManager.shared.openAIAPIKey)
        } catch {
            print("⚠️ Configuration error: \(error.localizedDescription)")
            // App will still work but speech recognition will fail
        }
        self.speechService = speechService ?? SpeechRecognitionService(whisperService: whisperService)
    }
    
    // MARK: - Public Methods
    
    func startRecording() {
        guard TextValidator.validateText(inputText).isValid else {
            showAlert("Please enter valid text before recording.")
            return
        }
        
        appState = .recording
        recordingStartTime = Date()
    }
    
    func processRecording(url: URL) {
        appState = .processing
        
        Task {
            do {
                print("🎤 Starting to process recording...")
                
                // Transcribe audio
                print("🔄 Transcribing audio...")
                let transcribedText = try await speechService.transcribeAudio(from: url)
                print("✅ Transcription completed: \(transcribedText.prefix(50))...")
                
                let confidenceScore = speechService.getConfidenceScore()
                print("📊 Confidence score: \(confidenceScore)")
                
                // Calculate metrics
                let duration = recordingStartTime?.timeIntervalSinceNow.magnitude ?? 0
                let wordCount = TextValidator.countWords(in: inputText)
                let wpm = accuracyAnalyzer.calculateWPM(wordCount: wordCount, duration: duration)
                print("⏱️ Duration: \(duration)s, WPM: \(wpm)")
                
                // Analyze accuracy
                print("🔍 Analyzing accuracy...")
                let accuracyResult = accuracyAnalyzer.compareTexts(
                    original: inputText,
                    spoken: transcribedText
                )
                print("📈 Accuracy: \(accuracyResult.overallAccuracy)")
                
                // Create metrics
                let metrics = ReadingMetrics(
                    accuracy: accuracyResult.overallAccuracy,
                    wpm: wpm,
                    duration: duration,
                    wordCount: wordCount,
                    completionRate: accuracyResult.completionRate,
                    confidenceScore: Double(confidenceScore),
                    addedWords: accuracyResult.addedWords,
                    missedWords: accuracyResult.missedWords
                )
                
                // Calculate game score
                print("🎮 Calculating game score...")
                let gameScore = gameEngine.calculateOverallScore(metrics)
                print("🏆 Overall score: \(gameScore.overallScore)")
                
                // Create session
                let session = ReadingSession(
                    originalText: inputText,
                    recordingURL: url,
                    transcribedText: transcribedText,
                    metrics: metrics,
                    score: gameScore
                )
                
                // Save the session
                do {
                    print("💾 Saving session...")
                    try persistenceService.saveSession(session)
                    print("✅ Session saved successfully")
                } catch {
                    print("⚠️ Failed to save session: \(error.localizedDescription)")
                    // Continue anyway - don't block the user experience
                }
                
                print("🎯 Updating UI to show results...")
                await MainActor.run {
                    self.currentSession = session
                    self.appState = .results
                }
                print("✅ Processing completed successfully!")
                
            } catch {
                print("❌ Error during processing: \(error)")
                let errorMessage = ErrorHandler.userFriendlyMessage(for: error)
                let recoverySuggestion = ErrorHandler.recoverySuggestion(for: error)
                
                let fullMessage = recoverySuggestion != nil ? 
                    "\(errorMessage)\n\n\(recoverySuggestion!)" : errorMessage
                
                await MainActor.run {
                    self.appState = .error(fullMessage)
                }
            }
        }
    }
    
    func cancelRecording() {
        appState = .textInput
        recordingStartTime = nil
    }
    
    func retryRecording() {
        appState = .recording
        recordingStartTime = Date()
    }
    
    func startNewSession() {
        inputText = ""
        currentSession = nil
        appState = .textInput
        recordingStartTime = nil
    }
    
    func retryFromError() {
        switch appState {
        case .error:
            if currentSession != nil {
                appState = .results
            } else {
                appState = .recording
            }
        default:
            appState = .textInput
        }
    }
    
    func dismissAlert() {
        showingAlert = false
        alertMessage = ""
    }
    
    // MARK: - Private Methods
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}