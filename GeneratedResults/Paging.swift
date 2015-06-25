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
    mutating func next(fetchNextBatch: Fetch, onFinish: ((Element) -> Void)?)
}

/// Generator is the class because struct is captured in asynchronous operations so offset won't update.
class PagingGenerator<T>: AsyncGeneratorType {
    typealias Element = Array<T>
    typealias Fetch = (offset: Int, limit: Int, completion: (result: Element) -> Void) -> Void
    
    var offset:Int
    let limit: Int
    
    init(startOffset: Int = 0, limit: Int = 25) {
        self.offset = startOffset
        self.limit = limit
    }
    
    func next(fetchNextBatch: Fetch, onFinish: ((Element) -> Void)? = nil) {
        fetchNextBatch(offset: offset, limit: limit) { [unowned self] (elements) in
            onFinish?(elements)
            self.offset += elements.count
        }
    }
}

protocol foo:SequenceType {
    
}

////MARK: Sequence
//
//protocol AsyncSequenceType: SequenceType {
//    typealias Generator : AsyncGeneratorType
//    func generate() -> Generator
//}
//
//struct Paging<T>: AsyncSequenceType {
//    typealias Generator = PagingGenerator<T>
//    
//    let startOffset: Int
//    let limit: Int
//    
//    func generate() -> Generator {
//        return Generator(startOffset: startOffset, limit: limit)
//    }
//}
