import Foundation

protocol WhisperAPIServiceProtocol {
    func configureAPIKey(_ key: String)
    func transcribeAudio(fileURL: URL) async throws -> WhisperResponse
    func estimateCost(duration: TimeInterval) -> Double
}

enum WhisperAPIError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case networkError(String)
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "OpenAI API key not configured"
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from Whisper API"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

struct WhisperAPIResponse: Codable {
    let text: String
}

class WhisperAPIService: WhisperAPIServiceProtocol {
    private var apiKey: String = ""
    private let baseURL = "https://api.openai.com/v1/audio/transcriptions"
    private let session = URLSession.shared
    
    func configureAPIKey(_ key: String) {
        self.apiKey = key
    }
    
    func transcribeAudio(fileURL: URL) async throws -> WhisperResponse {
        guard !apiKey.isEmpty else {
            throw WhisperAPIError.noAPIKey
        }
        
        guard let url = URL(string: baseURL) else {
            throw WhisperAPIError.invalidURL
        }
        
        // Read audio file data
        let audioData: Data
        do {
            audioData = try Data(contentsOf: fileURL)
        } catch {
            throw WhisperAPIError.networkError("Failed to read audio file: \(error.localizedDescription)")
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        // Add file parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add response format parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("json\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Make the request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WhisperAPIError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                // Try to parse error response
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorData["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw WhisperAPIError.apiError(message)
                } else {
                    throw WhisperAPIError.apiError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Parse successful response
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(WhisperAPIResponse.self, from: data)
            
            // For now, we'll use a fixed confidence score since Whisper API doesn't provide it
            // In a real implementation, you might want to analyze the response for confidence indicators
            return WhisperResponse(text: apiResponse.text, confidence: 0.95)
            
        } catch let error as WhisperAPIError {
            throw error
        } catch {
            throw WhisperAPIError.networkError(error.localizedDescription)
        }
    }
    
    func estimateCost(duration: TimeInterval) -> Double {
        // $0.006 per minute
        let minutes = duration / 60.0
        return minutes * 0.006
    }
}