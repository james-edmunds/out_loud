import Foundation
import Combine

class TextInputViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var validationResult: ValidationResult = ValidationResult(isValid: false, errorMessage: nil, wordCount: 0, characterCount: 0)
    @Published var isValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Validate text whenever it changes
        $inputText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.validateText(text)
            }
            .store(in: &cancellables)
    }
    
    func validateText(_ text: String) {
        validationResult = TextValidator.validateText(text)
        isValid = validationResult.isValid
    }
    
    func clearText() {
        inputText = ""
    }
    
    func getProcessedText() -> String {
        return TextValidator.prepareTextForComparison(inputText)
    }
    
    func getWordCount() -> Int {
        return TextValidator.countWords(in: inputText)
    }
}