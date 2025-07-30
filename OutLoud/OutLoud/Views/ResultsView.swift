import SwiftUI

struct ResultsView: View {
    let session: ReadingSession
    let onRetry: () -> Void
    let onNewSession: () -> Void
    
    @State private var showingDetails = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Reading Results")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Here's how you did!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Overall Score Card
                VStack(spacing: 16) {
                    Text("Overall Score")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(session.score.overallScore) / 100)
                            .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("\(session.score.overallScore)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(scoreColor)
                            Text("/ 100")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(overallFeedback)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                
                // Metrics Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    // Accuracy Card
                    MetricCard(
                        title: "Accuracy",
                        value: "\(Int(session.metrics.accuracy * 100))%",
                        subtitle: accuracySubtitle,
                        color: accuracyColor,
                        icon: "checkmark.circle.fill"
                    )
                    
                    // WPM Card
                    MetricCard(
                        title: "Reading Speed",
                        value: "\(Int(session.metrics.wpm)) WPM",
                        subtitle: wpmSubtitle,
                        color: wpmColor,
                        icon: "speedometer"
                    )
                    
                    // Completion Card
                    MetricCard(
                        title: "Completion",
                        value: "\(Int(session.metrics.completionRate * 100))%",
                        subtitle: completionSubtitle,
                        color: completionColor,
                        icon: "flag.checkered"
                    )
                    
                    // Confidence Card
                    MetricCard(
                        title: "Clarity",
                        value: "\(Int(session.metrics.confidenceScore * 100))%",
                        subtitle: "Speech recognition confidence",
                        color: confidenceColor,
                        icon: "waveform"
                    )
                }
                
                // Detailed Feedback
                if showingDetails {
                    DetailedFeedbackView(metrics: session.metrics)
                        .transition(.opacity.combined(with: .slide))
                }
                
                Button(showingDetails ? "Hide Details" : "Show Details") {
                    withAnimation(.easeInOut) {
                        showingDetails.toggle()
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(.blue)
                
                // Achievements
                if !session.score.achievements.isEmpty {
                    AchievementsView(achievements: session.score.achievements)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Try Again") {
                        onRetry()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("New Text") {
                        onNewSession()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    // MARK: - Computed Properties
    
    private var scoreColor: Color {
        switch session.score.overallScore {
        case 90...100:
            return .green
        case 70..<90:
            return .orange
        default:
            return .red
        }
    }
    
    private var overallFeedback: String {
        switch session.score.overallScore {
        case 90...100:
            return "Excellent reading! You nailed it! 🎉"
        case 80..<90:
            return "Great job! Just a few areas to improve."
        case 70..<80:
            return "Good effort! Keep practicing to improve."
        case 60..<70:
            return "Not bad! Focus on accuracy and pace."
        default:
            return "Keep practicing! You'll get better with time."
        }
    }
    
    private var accuracySubtitle: String {
        let errorCount = session.metrics.addedWords.count + session.metrics.missedWords.count
        if errorCount == 0 {
            return "Perfect accuracy!"
        } else if errorCount == 1 {
            return "1 error"
        } else {
            return "\(errorCount) errors"
        }
    }
    
    private var accuracyColor: Color {
        session.metrics.accuracy >= 0.95 ? .green : session.metrics.accuracy >= 0.8 ? .orange : .red
    }
    
    private var wpmSubtitle: String {
        let analyzer = AccuracyAnalyzer()
        let performance = analyzer.evaluateWPMPerformance(session.metrics.wpm)
        return performance.description
    }
    
    private var wpmColor: Color {
        let analyzer = AccuracyAnalyzer()
        let performance = analyzer.evaluateWPMPerformance(session.metrics.wpm)
        switch performance.color {
        case "green":
            return .green
        case "orange":
            return .orange
        default:
            return .red
        }
    }
    
    private var completionSubtitle: String {
        if session.metrics.completionRate >= 1.0 {
            return "Finished the entire text"
        } else {
            let percentage = Int(session.metrics.completionRate * 100)
            return "Read \(percentage)% of the text"
        }
    }
    
    private var completionColor: Color {
        session.metrics.completionRate >= 0.9 ? .green : session.metrics.completionRate >= 0.7 ? .orange : .red
    }
    
    private var confidenceColor: Color {
        session.metrics.confidenceScore >= 0.9 ? .green : session.metrics.confidenceScore >= 0.7 ? .orange : .red
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct DetailedFeedbackView: View {
    let metrics: ReadingMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Feedback")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !metrics.missedWords.isEmpty {
                FeedbackSection(
                    title: "Missed Words (\(metrics.missedWords.count))",
                    items: metrics.missedWords,
                    color: .red,
                    icon: "minus.circle"
                )
            }
            
            if !metrics.addedWords.isEmpty {
                FeedbackSection(
                    title: "Extra Words (\(metrics.addedWords.count))",
                    items: metrics.addedWords,
                    color: .orange,
                    icon: "plus.circle"
                )
            }
            
            // Reading Stats
            VStack(alignment: .leading, spacing: 4) {
                Label("Reading Statistics", systemImage: "chart.bar")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Duration: \(formatDuration(metrics.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Words read: \(metrics.wordCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct FeedbackSection: View {
    let title: String
    let items: [String]
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80))
            ], spacing: 4) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.1))
                        .foregroundColor(color)
                        .cornerRadius(4)
                }
            }
        }
    }
}

struct AchievementsView: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements Unlocked! 🏆")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 200))
            ], spacing: 12) {
                ForEach(achievements) { achievement in
                    HStack {
                        Image(systemName: achievement.iconName)
                            .foregroundColor(.yellow)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(achievement.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

#Preview {
    let sampleMetrics = ReadingMetrics(
        accuracy: 0.92,
        wpm: 155,
        duration: 45,
        wordCount: 120,
        completionRate: 0.95,
        confidenceScore: 0.88,
        addedWords: ["um", "uh"],
        missedWords: ["the", "quick"]
    )
    
    let sampleScore = GameScore(
        overallScore: 87,
        accuracyScore: 92,
        speedScore: 100,
        completionScore: 95,
        achievements: [
            Achievement(name: "Speed Reader", description: "Hit the ideal reading speed", iconName: "bolt.fill"),
            Achievement(name: "Finisher", description: "Read the entire text", iconName: "checkmark.circle.fill")
        ]
    )
    
    let sampleSession = ReadingSession(
        originalText: "Sample text for reading",
        transcribedText: "Sample text for reading um uh",
        metrics: sampleMetrics,
        score: sampleScore
    )
    
    return ResultsView(
        session: sampleSession,
        onRetry: { print("Retry") },
        onNewSession: { print("New Session") }
    )
    .frame(width: 700, height: 800)
}