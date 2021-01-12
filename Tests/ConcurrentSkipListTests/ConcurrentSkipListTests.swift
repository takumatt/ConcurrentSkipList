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
  
  func testArray() {
    
    XCTContext.runActivity(named: "basic") { _ in
      
      let skipList: ConcurrentSkipList<Int, Int> = .init()
      let num = 20
      var ary: [Int] = []
      
      for i in 0 ..< num {
        let _ = skipList.insert(key: i, value: i)
        ary.append(i)
      }
      
      XCTAssertEqual(skipList.array.map(\.value), ary)
    }
  }
  
  func testExtension() {
    
    XCTContext.runActivity(named: "Inspecting") { _ in
      
      XCTContext.runActivity(named: "isEmpty") { _ in
        let skipList: ConcurrentSkipList<String, Int> = .init()
        XCTAssertTrue(skipList.isEmpty)
        let _ = skipList.insert(key: "\(1)", value: 1)
        XCTAssertFalse(skipList.isEmpty)
      }
    }
    
    XCTContext.runActivity(named: "Membership") { _ in
      
       XCTContext.runActivity(named: "contains") { _ in
        let skipList: ConcurrentSkipList<String, Int> = .init()
        XCTAssertFalse(skipList.contains(key: "\(1)"))
        let _ = skipList.insert(key: "\(1)", value: 1)
        XCTAssertTrue(skipList.contains(key: "\(1)"))
       }
    }
    

    XCTContext.runActivity(named: "Adding") { _ in
      
      XCTContext.runActivity(named: "update") { _ in
        let skipList: ConcurrentSkipList<String, Int> = .init()
        let insertResult = skipList.insert(key: "\(1)", value: 1)
        XCTAssertEqual(skipList.search(key: "\(1)")?.value, insertResult?.value)
        let updateResult = skipList.update(key: "\(1)", value: 2)
        XCTAssertEqual(skipList.search(key: "\(1)")?.value, updateResult?.value)
      }
    }
    
    XCTContext.runActivity(named: "Removing") { _ in
      
      XCTContext.runActivity(named: "filter") { _ in
        
        let skipList: ConcurrentSkipList<String, Int> = .init()
        
        (0 ..< 10).forEach { i in
          let _ = skipList.insert(key: "\(i)", value: i)
        }
        
        XCTAssertEqual(
          skipList.filter { $0.value.isMultiple(of: 2) }.map { $0.value },
          [0, 2, 4, 6, 8]
        )
      }

      XCTContext.runActivity(named: "removeFirst") { _ in
        
        let skipList: ConcurrentSkipList<String, Int> = .init()
        
        (0 ..< 10).forEach { i in
          let _ = skipList.insert(key: "\(i)", value: i)
        }
        
        XCTAssertTrue(skipList.contains(key: "\(0)"))
        XCTAssertEqual(skipList.first?.key, "\(0)")
        
        let _ = skipList.removeFirst()
        
        XCTAssertFalse(skipList.contains(key: "\(0)"))
        XCTAssertEqual(skipList.first?.key, "\(1)")
      }
      
      XCTContext.runActivity(named: "removeAll") { _ in
        
        let skipList: ConcurrentSkipList<String, Int> = .init()
        
        (0 ..< 10).forEach { i in
          let _ = skipList.insert(key: "\(i)", value: i)
        }
        
        XCTAssertFalse(skipList.isEmpty)
        
        skipList.removeAll()
        
        XCTAssertTrue(skipList.isEmpty)
      }
    }
    
    XCTContext.runActivity(named: "AccessIndividual") { _ in
      
      XCTContext.runActivity(named: "first") { _ in
        let skipList: ConcurrentSkipList<String, Int> = .init()
        XCTAssertNil(skipList.first)
        let result = skipList.insert(key: "\(1)", value: 1)
        XCTAssertEqual(skipList.first?.key, result?.key)
        XCTAssertEqual(skipList.first?.value, result?.value)
      }
    }
  }
  
  static var allTests = [
    ("testBasic", testBasic),
    ("testConcurrentPerform", testConcurrentPerform),
  ]
}
