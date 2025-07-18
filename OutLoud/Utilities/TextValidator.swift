import Foundation

struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
    let wordCount: Int
    let characterCount: Int
}

class TextValidator {
    static let maxCharacterCount = 10000
    static let minCharacterCount = 10
    static let maxWordCount = 2000
    
    static func validateText(_ text: String) -> ValidationResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if empty
        if trimmedText.isEmpty {
            return ValidationResult(
                isValid: false,
                errorMessage: "Please enter some text to read",
                wordCount: 0,
                characterCount: 0
            )
        }
        
        let characterCount = trimmedText.count
        let wordCount = countWords(in: trimmedText)
        
        // Check minimum length
        if characterCount < minCharacterCount {
            return ValidationResult(
                isValid: false,
                errorMessage: "Text is too short. Please enter at least \(minCharacterCount) characters",
                wordCount: wordCount,
                characterCount: characterCount
            )
        }
        
        // Check maximum length
        if characterCount > maxCharacterCount {
            return ValidationResult(
                isValid: false,
                errorMessage: "Text is too long. Please keep it under \(maxCharacterCount) characters",
                wordCount: wordCount,
                characterCount: characterCount
            )
        }
        
        // Check word count
        if wordCount > maxWordCount {
            return ValidationResult(
                isValid: false,
                errorMessage: "Text has too many words. Please keep it under \(maxWordCount) words",
                wordCount: wordCount,
                characterCount: characterCount
            )
        }
        
        return ValidationResult(
            isValid: true,
            errorMessage: nil,
            wordCount: wordCount,
            characterCount: characterCount
        )
    }
    
    static func countWords(in text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    static func prepareTextForComparison(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "[^a-zA-Z0-9\\s]", with: "", options: .regularExpression)
    }
}