import SwiftUI

enum AppState: Equatable {
    case textInput
    case recording
    case processing
    case results
    case error(String)
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                VStack(spacing: 8) {
                    Text("Out Loud")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Reading Practice App")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Reading Practice Application")
                }
                .padding(.top)
                
                Spacer()
                
                // Main Content Area
                Group {
                    switch viewModel.appState {
                    case .textInput:
                        TextInputView(text: $viewModel.inputText) {
                            viewModel.startRecording()
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        
                    case .recording:
                        RecordingView(
                            textToRead: viewModel.inputText,
                            onRecordingComplete: { url in
                                viewModel.processRecording(url: url)
                            },
                            onCancel: {
                                viewModel.cancelRecording()
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        
                    case .processing:
                        ProcessingView()
                            .transition(.opacity.combined(with: .scale))
                        
                    case .results:
                        if let session = viewModel.currentSession {
                            ResultsView(
                                session: session,
                                onRetry: {
                                    viewModel.retryRecording()
                                },
                                onNewSession: {
                                    viewModel.startNewSession()
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }
                        
                    case .error(let message):
                        ErrorView(
                            message: message,
                            onRetry: {
                                viewModel.retryFromError()
                            },
                            onStartOver: {
                                viewModel.startNewSession()
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(AppConstants.standardAnimation, value: viewModel.appState)
                
                Spacer()
            }
            .frame(minWidth: 700, minHeight: 500)
        }
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("OK") {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

struct ProcessingView: View {
    @State private var animationAmount = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .scaleEffect(animationAmount)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animationAmount)
                .onAppear {
                    animationAmount = 1.2
                }
                .accessibilityLabel("Processing recording")
            
            Text("Processing your recording...")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text("This may take a moment while we analyze your speech.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Please wait while we analyze your speech recording")
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onStartOver: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: errorIcon)
                .font(.system(size: 48))
                .foregroundColor(errorColor)
            
            Text(errorTitle)
                .font(.title2)
                .fontWeight(.semibold)
            
            ScrollView {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxHeight: 200)
            
            HStack(spacing: 16) {
                Button("Try Again") {
                    onRetry()
                }
                .buttonStyle(.bordered)
                
                Button("Start Over") {
                    onStartOver()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private var errorIcon: String {
        if message.contains("permission") || message.contains("microphone") {
            return "mic.slash"
        } else if message.contains("network") || message.contains("internet") {
            return "wifi.slash"
        } else if message.contains("API key") {
            return "key.slash"
        } else {
            return "exclamationmark.triangle"
        }
    }
    
    private var errorColor: Color {
        if message.contains("permission") {
            return .red
        } else if message.contains("network") {
            return .orange
        } else {
            return .yellow
        }
    }
    
    private var errorTitle: String {
        if message.contains("permission") || message.contains("microphone") {
            return "Microphone Access Required"
        } else if message.contains("network") || message.contains("internet") {
            return "Connection Problem"
        } else if message.contains("API key") {
            return "Configuration Required"
        } else {
            return "Something went wrong"
        }
    }
}

#Preview {
    MainView()
}