import XCTest

import ConcurrentSkipListTests

var tests = [XCTestCaseEntry]()
tests += ConcurrentSkipListTests.allTests()
XCTMain(tests)
