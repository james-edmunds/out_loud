import XCTest
@testable import OutLoud

class AccuracyAnalyzerTests: XCTestCase {
    var analyzer: AccuracyAnalyzer!
    
    override func setUp() {
        super.setUp()
        analyzer = AccuracyAnalyzer()
    }
    
    override func tearDown() {
        analyzer = nil
        super.tearDown()
    }
    
    // MARK: - WPM Calculation Tests
    
    func testCalculateWPM_ValidInput() {
        let wpm = analyzer.calculateWPM(wordCount: 150, duration: 60) // 1 minute
        XCTAssertEqual(wpm, 150.0, accuracy: 0.1)
    }
    
    func testCalculateWPM_ZeroDuration() {
        let wpm = analyzer.calculateWPM(wordCount: 100, duration: 0)
        XCTAssertEqual(wpm, 0.0)
    }
    
    func testCalculateWPM_TwoMinutes() {
        let wpm = analyzer.calculateWPM(wordCount: 300, duration: 120) // 2 minutes
        XCTAssertEqual(wpm, 150.0, accuracy: 0.1)
    }
    
    // MARK: - Text Comparison Tests
    
    func testCompareTexts_PerfectMatch() {
        let original = "Hello world this is a test"
        let spoken = "Hello world this is a test"
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertEqual(result.overallAccuracy, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.wordLevelAccuracy, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.completionRate, 1.0, accuracy: 0.01)
        XCTAssertTrue(result.addedWords.isEmpty)
        XCTAssertTrue(result.missedWords.isEmpty)
        XCTAssertEqual(result.totalWords, 6)
        XCTAssertEqual(result.spokenWords, 6)
    }
    
    func testCompareTexts_MissedWords() {
        let original = "Hello world this is a test"
        let spoken = "Hello world this is test" // missing "a"
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertLessThan(result.overallAccuracy, 1.0)
        XCTAssertLessThan(result.wordLevelAccuracy, 1.0)
        XCTAssertEqual(result.completionRate, 5.0/6.0, accuracy: 0.01) // 5 words spoken out of 6
        XCTAssertTrue(result.addedWords.isEmpty)
        XCTAssertEqual(result.missedWords.count, 1)
        XCTAssertTrue(result.missedWords.contains("a"))
    }
    
    func testCompareTexts_AddedWords() {
        let original = "Hello world test"
        let spoken = "Hello world this is a test" // added "this", "is", "a"
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertLessThan(result.overallAccuracy, 1.0)
        XCTAssertEqual(result.wordLevelAccuracy, 1.0, accuracy: 0.01) // All original words were spoken
        XCTAssertEqual(result.completionRate, 1.0, accuracy: 0.01) // More than 100% completion
        XCTAssertEqual(result.addedWords.count, 3)
        XCTAssertTrue(result.missedWords.isEmpty)
    }
    
    func testCompareTexts_PartialCompletion() {
        let original = "Hello world this is a long test sentence"
        let spoken = "Hello world this is" // stopped early
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertLessThan(result.completionRate, 1.0)
        XCTAssertEqual(result.completionRate, 4.0/8.0, accuracy: 0.01) // 4 words out of 8
        XCTAssertEqual(result.missedWords.count, 4) // "a", "long", "test", "sentence"
    }
    
    func testCompareTexts_CaseInsensitive() {
        let original = "Hello World This Is A Test"
        let spoken = "hello world this is a test"
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertEqual(result.overallAccuracy, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.wordLevelAccuracy, 1.0, accuracy: 0.01)
        XCTAssertTrue(result.addedWords.isEmpty)
        XCTAssertTrue(result.missedWords.isEmpty)
    }
    
    func testCompareTexts_PunctuationIgnored() {
        let original = "Hello, world! This is a test."
        let spoken = "Hello world This is a test"
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertEqual(result.overallAccuracy, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.wordLevelAccuracy, 1.0, accuracy: 0.01)
        XCTAssertTrue(result.addedWords.isEmpty)
        XCTAssertTrue(result.missedWords.isEmpty)
    }
    
    func testCompareTexts_EmptySpoken() {
        let original = "Hello world"
        let spoken = ""
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertEqual(result.overallAccuracy, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.wordLevelAccuracy, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.completionRate, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.missedWords.count, 2)
        XCTAssertTrue(result.addedWords.isEmpty)
    }
    
    // MARK: - Mispronunciation Tests
    
    func testIdentifyMispronunciations_SimilarWords() {
        let result = AccuracyResult(
            overallAccuracy: 0.8,
            wordLevelAccuracy: 0.8,
            completionRate: 1.0,
            addedWords: ["wurld", "tast"], // mispronounced versions
            missedWords: ["world", "test"], // original words
            totalWords: 4,
            spokenWords: 4
        )
        
        let mispronunciations = analyzer.identifyMispronunciations(result)
        
        XCTAssertEqual(mispronunciations.count, 2)
        
        // Check if "world" -> "wurld" is identified
        let worldMispronunciation = mispronunciations.first { $0.originalWord == "world" }
        XCTAssertNotNil(worldMispronunciation)
        XCTAssertEqual(worldMispronunciation?.spokenWord, "wurld")
        
        // Check if "test" -> "tast" is identified
        let testMispronunciation = mispronunciations.first { $0.originalWord == "test" }
        XCTAssertNotNil(testMispronunciation)
        XCTAssertEqual(testMispronunciation?.spokenWord, "tast")
    }
    
    func testIdentifyMispronunciations_NoSimilarWords() {
        let result = AccuracyResult(
            overallAccuracy: 0.5,
            wordLevelAccuracy: 0.5,
            completionRate: 1.0,
            addedWords: ["completely", "different"], // completely different words
            missedWords: ["hello", "world"],
            totalWords: 4,
            spokenWords: 4
        )
        
        let mispronunciations = analyzer.identifyMispronunciations(result)
        
        XCTAssertTrue(mispronunciations.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testCompareTexts_BothEmpty() {
        let result = analyzer.compareTexts(original: "", spoken: "")
        
        XCTAssertEqual(result.overallAccuracy, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.wordLevelAccuracy, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.completionRate, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.totalWords, 0)
        XCTAssertEqual(result.spokenWords, 0)
    }
    
    func testCompareTexts_WhitespaceOnly() {
        let original = "   "
        let spoken = "\t\n  "
        
        let result = analyzer.compareTexts(original: original, spoken: spoken)
        
        XCTAssertEqual(result.totalWords, 0)
        XCTAssertEqual(result.spokenWords, 0)
    }
} 
   
    // MARK: - WPM Performance Evaluation Tests
    
    func testEvaluateWPMPerformance_TooSlow() {
        let performance = analyzer.evaluateWPMPerformance(80)
        
        if case .tooSlow = performance {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .tooSlow, got \(performance)")
        }
    }
    
    func testEvaluateWPMPerformance_BelowTarget() {
        let performance = analyzer.evaluateWPMPerformance(130)
        
        if case .belowTarget = performance {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .belowTarget, got \(performance)")
        }
    }
    
    func testEvaluateWPMPerformance_Ideal() {
        let performance = analyzer.evaluateWPMPerformance(155)
        
        if case .ideal = performance {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .ideal, got \(performance)")
        }
    }
    
    func testEvaluateWPMPerformance_AboveTarget() {
        let performance = analyzer.evaluateWPMPerformance(170)
        
        if case .aboveTarget = performance {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .aboveTarget, got \(performance)")
        }
    }
    
    func testEvaluateWPMPerformance_TooFast() {
        let performance = analyzer.evaluateWPMPerformance(250)
        
        if case .tooFast = performance {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .tooFast, got \(performance)")
        }
    }
    
    func testCalculateWPMScore_IdealSpeed() {
        let score = analyzer.calculateWPMScore(155) // Ideal range
        XCTAssertEqual(score, 100)
    }
    
    func testCalculateWPMScore_BelowTarget() {
        let score = analyzer.calculateWPMScore(125) // Below target
        XCTAssertGreaterThan(score, 70)
        XCTAssertLessThan(score, 100)
    }
    
    func testCalculateWPMScore_AboveTarget() {
        let score = analyzer.calculateWPMScore(175) // Above target
        XCTAssertGreaterThan(score, 70)
        XCTAssertLessThan(score, 100)
    }
    
    func testCalculateWPMScore_TooSlow() {
        let score = analyzer.calculateWPMScore(50) // Too slow
        XCTAssertGreaterThanOrEqual(score, 10)
        XCTAssertLessThan(score, 70)
    }
    
    func testCalculateWPMScore_TooFast() {
        let score = analyzer.calculateWPMScore(300) // Too fast
        XCTAssertGreaterThanOrEqual(score, 10)
        XCTAssertLessThan(score, 70)
    }
    
    func testGetTargetWPMRange() {
        let range = analyzer.getTargetWPMRange()
        XCTAssertEqual(range.lowerBound, 150.0)
        XCTAssertEqual(range.upperBound, 160.0)
    }
    
    func testGetAcceptableWPMRange() {
        let range = analyzer.getAcceptableWPMRange()
        XCTAssertEqual(range.lowerBound, 120.0)
        XCTAssertEqual(range.upperBound, 180.0)
    }