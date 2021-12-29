//
//  Queue.swift
//  BankManagerConsoleApp
//
//  Created by 이차민 on 2021/12/21.
//

import Foundation
@propertyWrapper
struct Atomic<Value> {

    private var value: Value
    private let lock = NSLock()

    init(wrappedValue value: Value) {
        self.value = value
    }

    var wrappedValue: Value {
      get { return load() }
      set { store(newValue: newValue) }
    }

    func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}

class Queue<Element> {
    @Atomic private var items = LinkedList<Element>()
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    func enqueue(value: Element) {
        items.append(value: value)
    }
    
    func dequeue() -> Element? {
        items.removeFirst()
    }
    
    func clear() {
        items.removeAll()
    }
    
    func peek() -> Element? {
        items.retrieveFirst()
    }
}
