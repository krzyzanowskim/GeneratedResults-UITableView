//
//  Paging.swift
//  GeneratedResults
//
//  Created by Marcin Krzyzanowski on 22/06/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

//MARK: Generator

protocol AsyncGeneratorType {
    typealias Element
    typealias Fetch
    mutating func next(fetchNextBatch: Fetch)
}

/// Generator is the class because struct is captured in asynchronous operations so offset won't update.
class PagingGenerator<T>: AsyncGeneratorType {
    typealias Element = Array<T>
    typealias Fetch = (offset: Int, limit: Int, completion: (result: Element) -> Void) -> Void
    
    private let queue = dispatch_queue_create("Paging lock queue", DISPATCH_QUEUE_SERIAL)
    
    var offset:Int
    let limit: Int
    
    init(offset: Int = 0, limit: Int = 25) {
        self.offset = offset
        self.limit = limit
    }
    
    func next(fetchNextBatch: Fetch) {
        fetchNextBatch(offset: self.offset, limit: self.limit) { (elements) in
            dispatch_sync(self.queue) {
                self.offset += elements.count
            }
        }
    }
}

//MARK: Sequence

protocol AsyncSequenceType: _SequenceType {
    typealias Generator : AsyncGeneratorType
    func generate() -> Generator
}

struct Paging<T>: AsyncSequenceType {
    typealias Generator = PagingGenerator<T>
    
    let offset: Int
    let limit: Int
    
    func generate() -> Generator {
        return Generator(offset: offset, limit: limit)
    }
}
