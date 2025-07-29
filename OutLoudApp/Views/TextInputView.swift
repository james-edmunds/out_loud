import SwiftUI

struct TextInputView: View {
    @Binding var text: String
    @State private var validationResult: ValidationResult = ValidationResult(isValid: true, errorMessage: nil, wordCount: 0, characterCount: 0)
    
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Text to Read")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Paste or type the text you'd like to practice reading aloud.")
                .foregroundColor(.secondary)
            
            // Text Editor
            ScrollView {
                TextEditor(text: $text)
                    .font(.body)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(validationResult.isValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
                    .frame(minHeight: 200)
            }
            .frame(maxHeight: 300)
            
            // Character and word count
            HStack {
                Text("\(validationResult.wordCount) words")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(validationResult.characterCount) characters")
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            
            // Error message
            if let errorMessage = validationResult.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Action buttons
            HStack {
                Button("Clear") {
                    text = ""
                    updateValidation()
                }
                .disabled(text.isEmpty)
                
                Spacer()
                
                Button("Continue") {
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!validationResult.isValid)
            }
        }
        .padding()
        .onChange(of: text) { _ in
            updateValidation()
        }
        .onAppear {
            updateValidation()
        }
    }
    
    private func updateValidation() {
        validationResult = TextValidator.validateText(text)
    }
}

#Preview {
    TextInputView(text: .constant("Sample text for reading practice.")) {
        print("Continue tapped")
    }
    .frame(width: 500, height: 400)
}