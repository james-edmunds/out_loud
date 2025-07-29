import XCTest
@testable import OutLoud

class TextValidatorTests: XCTestCase {
    
    func testValidateText_EmptyText_ReturnsInvalid() {
        let result = TextValidator.validateText("")
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.wordCount, 0)
        XCTAssertEqual(result.characterCount, 0)
        XCTAssertNotNil(result.errorMessage)
    }
    
    func testValidateText_TooShort_ReturnsInvalid() {
        let result = TextValidator.validateText("Hi")
        
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.errorMessage)
        XCTAssertTrue(result.errorMessage!.contains("too short"))
    }
    
    func testValidateText_ValidText_ReturnsValid() {
        let text = "This is a valid text for reading practice with enough characters."
        let result = TextValidator.validateText(text)
        
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.errorMessage)
        XCTAssertGreaterThan(result.wordCount, 0)
        XCTAssertGreaterThan(result.characterCount, 0)
    }
    
    func testValidateText_TooLong_ReturnsInvalid() {
        let longText = String(repeating: "This is a very long text. ", count: 500)
        let result = TextValidator.validateText(longText)
        
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.errorMessage)
        XCTAssertTrue(result.errorMessage!.contains("too long"))
    }
    
    func testCountWords_ValidText_ReturnsCorrectCount() {
        let text = "Hello world this is a test"
        let count = TextValidator.countWords(in: text)
        
        XCTAssertEqual(count, 6)
    }
    
    func testCountWords_EmptyText_ReturnsZero() {
        let count = TextValidator.countWords(in: "")
        
        XCTAssertEqual(count, 0)
    }
    
    func testPrepareTextForComparison_RemovesPunctuation() {
        let text = "Hello, world! This is a test."
        let prepared = TextValidator.prepareTextForComparison(text)
        
        XCTAssertEqual(prepared, "hello world this is a test")
    }
    
    func testPrepareTextForComparison_TrimsWhitespace() {
        let text = "  Hello world  "
        let prepared = TextValidator.prepareTextForComparison(text)
        
        XCTAssertEqual(prepared, "hello world")
    }
}