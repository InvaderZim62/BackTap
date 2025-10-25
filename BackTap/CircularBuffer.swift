//
//  CircularBuffer.swift
//  BackTap
//
//  Created by Phil Stern on 10/24/25.
//
//  CircularBuffer is a generic struct.  Specify the type of data stored in the buffer on declaration
//  of an instance.
//  ex.
//    let circularBuffer = CircularBuffer<String>(size: 4)
//    let circularBuffer = CircularBuffer<Int>(size: 10)
//    let circularBuffer = CircularBuffer<Any>(size: 20)
//
//  Note: This version of the circular buffer is implemented as a FIFO
//
//  ex. buffer size 5
//    add 1, 2, 3   1 2 3 - -   remove returns 1   1 2 3 - -
//                  t     h                          t   h     h = headIndex, t = tailIndex
//
//    add 4         1 2 3 4 -   remove returns 1   1 2 3 4 -
//                  t       h                        t     h
//
//    add 5         1 2 3 4 5   remove returns 2   1 2 3 4 5   note: it doesn't return 1, since head is pointing to it;
//                  h t                            h   t             it's treated as if the buffer is one less in size
//
//    add 6         6 2 3 4 5   remove returns 3   6 2 3 4 5
//                    h t                            h   t
//

import Foundation

struct CircularBuffer<T> {

    private var buffer = [T]()
    private(set) var length = 0
    private var headIndex = 0  // points to next index to overwrite
    private var tailIndex = 0  // points to next index to remove
    
    // max value in buffer
    var maxInt16: Int16? {
        guard T.self is Int16.Type && buffer.count > 0 else { return nil }
        
        var maxVal = buffer[0] as! Int16
        for val in buffer {
            let val16 = val as! Int16
            if val16 > maxVal {
                maxVal = val16
            }
        }
        return maxVal
    }
    
    init(size: Int) {
        length = size + 1  // dimension buffer one more than needed
    }
    
    var count: Int {
        var bufferCount = headIndex - tailIndex
        bufferCount = bufferCount >= 0 ? bufferCount : bufferCount + buffer.count
        return bufferCount
    }
    
    mutating func add(_ element: T) {
        if buffer.count < length {
            buffer.append(element)  // append until full
        } else {
            buffer[headIndex] = element  // overwrite when full
        }
        headIndex = (headIndex + 1) % length
        if headIndex == tailIndex {
            tailIndex = (tailIndex + 1) % length
        }
    }
    
    // get oldest and return it (FIFO)
    mutating func remove() -> T? {
        if tailIndex == headIndex {
            return nil  // buffer is empty
        } else {
            let oldestValue = buffer[tailIndex]
            tailIndex = (tailIndex + 1) % length
            return oldestValue
        }
    }
    
    // return whole buffer from oldest to newest entry
    func get() -> [T] {
        if tailIndex == headIndex {
            return []
        } else if tailIndex < headIndex {
            return Array(buffer[tailIndex..<headIndex])
        } else {
            return Array(buffer[tailIndex..<length]) + Array(buffer[0..<headIndex])
        }
    }

    mutating func clear() {
        headIndex = 0
        tailIndex = 0
    }
}
