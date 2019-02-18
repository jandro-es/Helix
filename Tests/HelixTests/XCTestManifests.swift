import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(HelixTests.allTests),
        testCase(GraphDefinitionsTests.allTests)
    ]
}
#endif
