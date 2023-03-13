//
//  DataReader.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 10.03.23.
//

import Foundation

class DataReader {
    let data: Data
    private var cursor: Int = 0
    init(_ data: Data) {
        self.data = data
    }
    func readNext<T>() -> T {
        // Get the number of bytes occupied by the type T
        let chunkSize = MemoryLayout<T>.size
        // Get the bytes that contain next value
        let nextDataChunk = Data(data[cursor..<cursor+chunkSize])
        // Read the actual value from the data chunk
        let value = nextDataChunk.withUnsafeBytes { bufferPointer in
            bufferPointer.load(fromByteOffset: 0, as: T.self)
        }
        // Move the cursor to the next position
        cursor += chunkSize
        // Return the value that we just read
        return value
    }
}
