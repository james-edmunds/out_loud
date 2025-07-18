import Foundation

protocol PersistenceServiceProtocol {
    func saveSession(_ session: ReadingSession) throws
    func loadSessions() throws -> [ReadingSession]
    func deleteSession(withId id: UUID) throws
    func getSessionCount() -> Int
    func getAverageScore() -> Double
    func getBestScore() -> Int
}

enum PersistenceError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode session data"
        case .decodingFailed:
            return "Failed to decode session data"
        case .saveFailed:
            return "Failed to save session"
        case .loadFailed:
            return "Failed to load sessions"
        }
    }
}

class PersistenceService: PersistenceServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "OutLoud.ReadingSessions"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func saveSession(_ session: ReadingSession) throws {
        var sessions = try loadSessions()
        
        // Remove any existing session with the same ID (for updates)
        sessions.removeAll { $0.id == session.id }
        
        // Add the new session
        sessions.append(session)
        
        // Sort by timestamp (newest first)
        sessions.sort { $0.timestamp > $1.timestamp }
        
        // Keep only the last 100 sessions to prevent unlimited growth
        if sessions.count > 100 {
            sessions = Array(sessions.prefix(100))
        }
        
        do {
            let data = try encoder.encode(sessions)
            userDefaults.set(data, forKey: sessionsKey)
        } catch {
            throw PersistenceError.encodingFailed
        }
    }
    
    func loadSessions() throws -> [ReadingSession] {
        guard let data = userDefaults.data(forKey: sessionsKey) else {
            return [] // No sessions saved yet
        }
        
        do {
            let sessions = try decoder.decode([ReadingSession].self, from: data)
            return sessions.sorted { $0.timestamp > $1.timestamp }
        } catch {
            throw PersistenceError.decodingFailed
        }
    }
    
    func deleteSession(withId id: UUID) throws {
        var sessions = try loadSessions()
        sessions.removeAll { $0.id == id }
        
        do {
            let data = try encoder.encode(sessions)
            userDefaults.set(data, forKey: sessionsKey)
        } catch {
            throw PersistenceError.saveFailed
        }
    }
    
    func getSessionCount() -> Int {
        do {
            let sessions = try loadSessions()
            return sessions.count
        } catch {
            return 0
        }
    }
    
    func getAverageScore() -> Double {
        do {
            let sessions = try loadSessions()
            guard !sessions.isEmpty else { return 0.0 }
            
            let totalScore = sessions.reduce(0) { $0 + $1.score.overallScore }
            return Double(totalScore) / Double(sessions.count)
        } catch {
            return 0.0
        }
    }
    
    func getBestScore() -> Int {
        do {
            let sessions = try loadSessions()
            return sessions.map { $0.score.overallScore }.max() ?? 0
        } catch {
            return 0
        }
    }
}

// MARK: - Progress Tracking Extensions
extension PersistenceService {
    func getRecentSessions(limit: Int = 10) throws -> [ReadingSession] {
        let sessions = try loadSessions()
        return Array(sessions.prefix(limit))
    }
    
    func getSessionsForDateRange(from startDate: Date, to endDate: Date) throws -> [ReadingSession] {
        let sessions = try loadSessions()
        return sessions.filter { session in
            session.timestamp >= startDate && session.timestamp <= endDate
        }
    }
    
    func getProgressStats() -> ProgressStats {
        do {
            let sessions = try loadSessions()
            guard !sessions.isEmpty else {
                return ProgressStats()
            }
            
            let totalSessions = sessions.count
            let averageAccuracy = sessions.map { $0.metrics.accuracy }.reduce(0, +) / Double(totalSessions)
            let averageWPM = sessions.map { $0.metrics.wpm }.reduce(0, +) / Double(totalSessions)
            let averageScore = sessions.map { Double($0.score.overallScore) }.reduce(0, +) / Double(totalSessions)
            let bestScore = sessions.map { $0.score.overallScore }.max() ?? 0
            
            // Calculate improvement trend (last 5 vs previous 5)
            let improvementTrend: Double
            if totalSessions >= 10 {
                let recent5 = Array(sessions.prefix(5))
                let previous5 = Array(sessions.dropFirst(5).prefix(5))
                
                let recentAvg = recent5.map { Double($0.score.overallScore) }.reduce(0, +) / 5.0
                let previousAvg = previous5.map { Double($0.score.overallScore) }.reduce(0, +) / 5.0
                
                improvementTrend = recentAvg - previousAvg
            } else {
                improvementTrend = 0.0
            }
            
            return ProgressStats(
                totalSessions: totalSessions,
                averageAccuracy: averageAccuracy,
                averageWPM: averageWPM,
                averageScore: averageScore,
                bestScore: bestScore,
                improvementTrend: improvementTrend
            )
        } catch {
            return ProgressStats()
        }
    }
}

struct ProgressStats {
    let totalSessions: Int
    let averageAccuracy: Double
    let averageWPM: Double
    let averageScore: Double
    let bestScore: Int
    let improvementTrend: Double // Positive means improving
    
    init(totalSessions: Int = 0, averageAccuracy: Double = 0.0, averageWPM: Double = 0.0, averageScore: Double = 0.0, bestScore: Int = 0, improvementTrend: Double = 0.0) {
        self.totalSessions = totalSessions
        self.averageAccuracy = averageAccuracy
        self.averageWPM = averageWPM
        self.averageScore = averageScore
        self.bestScore = bestScore
        self.improvementTrend = improvementTrend
    }
}