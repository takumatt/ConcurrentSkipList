import XCTest
@testable import ConcurrentSkipList

final class ConcurrentSkipListTests: XCTestCase {
  
  func testBasic() {
    
    let skipList: ConcurrentSkipList<String, Int> = .init()
    let num = 1000
    
    for i in 0 ..< num {
      let result = skipList.insert(key: "\(i)", value: i)
      XCTAssertEqual(result?.key, "\(i)")
      XCTAssertEqual(result?.value, i)
    }
    
    for i in 0 ..< num {
      let result = skipList.search(key: "\(i)")
      XCTAssertEqual(result?.key, "\(i)")
      XCTAssertEqual(result?.value, i)
    }
    
    for i in stride(from: (num - 1), through: 0, by: -1) {
      let result = skipList.remove(key: "\(i)")
      XCTAssertEqual(result?.key, "\(i)")
      XCTAssertEqual(result?.value, i)
      XCTAssertNil(skipList.search(key: "\(i)"))
    }
  }
  
  func testConcurrentPerform() {
        
    let skipList: ConcurrentSkipList<String, Int> = .init()
    let num = 1000
    
    DispatchQueue.concurrentPerform(iterations: num) { i in
      let result = skipList.insert(key: "\(i)", value: i)
      XCTAssertEqual(result?.key, "\(i)")
      XCTAssertEqual(result?.value, i)
    }
    
    DispatchQueue.concurrentPerform(iterations: num) { i in
      let result = skipList.search(key: "\(i)")
      XCTAssertEqual(result?.key, "\(i)")
      XCTAssertEqual(result?.value, i)
    }
    
    DispatchQueue.concurrentPerform(iterations: num) { i in
      let result = skipList.remove(key: "\(i)")
      XCTAssertEqual(result?.key, "\(i)")
      XCTAssertEqual(result?.value, i)
      XCTAssertNil(skipList.search(key: "\(i)"))
    }
  }
  
  static var allTests = [
    ("testBasic", testBasic),
    ("testConcurrentPerform", testConcurrentPerform),
  ]
}
