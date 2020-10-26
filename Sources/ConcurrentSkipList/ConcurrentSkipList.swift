import Foundation

public final class ElementNode<Key: Comparable, Value> {
  
  var next: [Element<Key, Value>?]
  
  init(next: [Element<Key, Value>?]) {
    self.next = next
  }
}

public final class Element<Key: Comparable, Value> {
  
  public let key: Key
  public var value: Value
  var elementNode: ElementNode<Key, Value>
  
  init(key: Key, value: Value, level: Int) {
    self.key = key
    self.value = value
    self.elementNode = .init(next: .init(repeating: nil, count: level))
  }
}

public final class ConcurrentSkipList<Key: Comparable, Value> {
  
  public struct Config {
    
    public let maxLevel: Int
    public let probability: Double
    
    public static var `default`: Config {
      .init(maxLevel: 18, probability: 1 / M_E)
    }
  }
  
  public var count: Int
  
  private var elementNode: ElementNode<Key, Value>
  private var maxLevel: Int
  private let probability: Double
  private let probTable: [Double]
  private let lock: NSLock = .init()
  private var prevNodesCache: [ElementNode<Key, Value>?]
  
  private let config: Config
  
  public init(config: Config = .default) {
    
    precondition(0 < config.maxLevel && config.maxLevel < 64)
    
    self.count = 0
    
    self.config = config
    
    self.elementNode = .init(next: .init(repeating: nil, count: config.maxLevel))
    self.prevNodesCache = .init(repeating: nil, count: config.maxLevel)
    self.maxLevel = config.maxLevel
    self.probability = config.probability
    self.probTable = Self.probabilityTable(probability: config.probability, maxLevel: config.maxLevel)
  }
  
  public func insert(key: Key, value: Value) -> Element<Key, Value>? {
    
    lock.lock()
    defer { lock.unlock() }
    
    var element: Element<Key, Value>?
    let prevs = getPrevElementNodes(key: key)
    
    element = prevs[0]?.next[0]
    if element != nil, let elementKey = element?.key, elementKey <= key {
      element!.value = value
      return element
    }
    
    element = .init(key: key, value: value, level: randomLevel())
    
    guard let count = element?.elementNode.next.count else { return nil }
    
    (0 ..< count).forEach { i in
      element?.elementNode.next[i] = prevs[i]?.next[i]
      prevs[i]?.next[i] = element
    }
    
    self.count += 1
    
    return element
  }
  
  public func remove(key: Key) -> Element<Key, Value>? {
    
    lock.lock()
    defer { lock.unlock() }
    
    let prevs = getPrevElementNodes(key: key)
    
    let element = prevs[0]?.next[0]
    
    if element != nil, let elementKey = element?.key, elementKey <= key {
      
      if let next = element?.elementNode.next {
      
        next.enumerated().forEach { (i, element) in
          prevs[i]?.next[i] = element
        }
        
        self.count -= 1
        return element
      }
    }
    
    return nil
  }
  
  public func search(key: Key) -> Element<Key, Value>? {
    
    lock.lock()
    defer { lock.unlock() }
    
    var prev = elementNode
    var next: Element<Key, Value>? = nil
    
    for i in stride(from: maxLevel - 1, through: 0, by: -1) {
      
      next = prev.next[i]
      
      while next != nil, let nextKey = next?.key, key > nextKey {
        prev = next!.elementNode
        next = next!.elementNode.next[i]
      }
    }
    
    if next != nil, let nextKey = next?.key, nextKey <= key {
      return next
    }
    
    return nil
  }
  
  private func getPrevElementNodes(key: Key) -> [ElementNode<Key, Value>?] {
    
    var prev = elementNode
    var next: Element<Key, Value>? = nil
    var prevs = prevNodesCache
    
    for i in stride(from: maxLevel - 1, through: 0, by: -1) {
      
      next = prev.next[i]
      
      while next != nil, let nextKey = next?.key, key > nextKey {
        
        prev = next!.elementNode
        next = next!.elementNode.next[i]
      }
      
      prevs[i] = prev
    }
    
    return prevs
  }
  
  private static func probabilityTable(probability: Double, maxLevel: Int) -> [Double] {
    (1 ... maxLevel).map { i in
      pow(probability, Double(i - 1))
    }
  }
  
  private func randomLevel() -> Int {
    
    let r = Double.random(in: 0 ... 1)
    var level = 1
    
    while level < maxLevel, r < probTable[level] {
      level += 1
    }
    
    return level
  }
}

extension ConcurrentSkipList {
  
  // MARK: - Inspecting a list
  
  public func isEmpty() -> Bool {
    elementNode.next[0] == nil
  }
  
  // MARK: - Testing for Membership

  public func contains(key: Key) -> Bool {
    self.search(key: key) != nil
  }
  
  // MARK: - Adding Elements
  
  public func update(key: Key, value: Value) -> Element<Key, Value>? {
    
    guard contains(key: key) else {
      return nil
    }
    
    return insert(key: key, value: value)
  }
  
  // MARK: - Removing Elements
  
  public func filter(
    _ isIncluded: @escaping (Element<Key, Value>) -> Bool
  ) -> [Element<Key, Value>] {
    
    var result: [Element<Key, Value>] = []
    var element = first
    
    while element != nil {
      
      if isIncluded(element!) {
        result.append(element!)
      }
      
      element = element?.elementNode.next[0]
    }
    
    return result
  }
  
  public func removeFirst() -> Element<Key, Value>? {
    
    guard let key = first?.key else {
      return nil
    }
    
    return self.remove(key: key)
  }
  
  public func removeAll() {

    self.count = 0

    self.elementNode = .init(next: .init(repeating: nil, count: config.maxLevel))
    self.prevNodesCache = .init(repeating: nil, count: config.maxLevel)
  }
  
  // MARK: - Accesing Individual Elements
  
  public var first: Element<Key, Value>? {
    elementNode.next[0]
  }
}
