import SwiftUI

enum RecordingState {
    case ready
    case recording
    case processing
    case error(String)
}

struct RecordingView: View {
    let textToRead: String
    let onRecordingComplete: (URL) -> Void
    let onCancel: () -> Void
    
    @StateObject private var viewModel = RecordingViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            // Text to read
            ScrollView {
                Text(textToRead)
                    .font(.body)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 200)
            
            Spacer()
            
            // Recording controls
            VStack(spacing: 16) {
                // Recording button
                Button(action: {
                    if viewModel.recordingState == .recording {
                        Task {
                            await viewModel.stopRecording()
                        }
                    } else {
                        Task {
                            await viewModel.startRecording()
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(recordingButtonColor)
                            .frame(width: 80, height: 80)
                            .scaleEffect(viewModel.recordingState == .recording ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: viewModel.recordingState == .recording)
                        
                        Image(systemName: recordingButtonIcon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.recordingState == .processing)
                
                // Recording status text
                Text(recordingStatusText)
                    .font(.headline)
                    .foregroundColor(recordingStatusColor)
                
                // Duration display
                if viewModel.recordingState == .recording {
                    Text(formatDuration(viewModel.recordingDuration))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                // Error message
                if case .error(let message) = viewModel.recordingState {
                    Text(message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .disabled(viewModel.recordingState == .recording || viewModel.recordingState == .processing)
                
                Spacer()
                
                if viewModel.recordingState == .processing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
        .padding()
        .onReceive(viewModel.$recordingDuration) { _ in
            // Update UI when duration changes
        }
        .onChange(of: viewModel.recordingURL) { url in
            if let url = url {
                onRecordingComplete(url)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var recordingButtonColor: Color {
        switch viewModel.recordingState {
        case .ready:
            return .blue
        case .recording:
            return .red
        case .processing:
            return .gray
        case .error:
            return .orange
        }
    }
    
    private var recordingButtonIcon: String {
        switch viewModel.recordingState {
        case .ready, .error:
            return "mic.fill"
        case .recording:
            return "stop.fill"
        case .processing:
            return "hourglass"
        }
    }
    
    private var recordingStatusText: String {
        switch viewModel.recordingState {
        case .ready:
            return "Tap to start recording"
        case .recording:
            return "Recording... Tap to stop"
        case .processing:
            return "Processing recording..."
        case .error:
            return "Error occurred"
        }
    }
    
    private var recordingStatusColor: Color {
        switch viewModel.recordingState {
        case .ready:
            return .primary
        case .recording:
            return .red
        case .processing:
            return .orange
        case .error:
            return .red
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    RecordingView(
        textToRead: "This is a sample text for reading practice. It contains multiple sentences to demonstrate the recording interface.",
        onRecordingComplete: { url in
            print("Recording completed: \(url)")
        },
        onCancel: {
            print("Recording cancelled")
        }
    )
    .frame(width: 600, height: 500)
}