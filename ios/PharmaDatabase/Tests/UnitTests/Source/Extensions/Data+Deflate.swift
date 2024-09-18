// Taken from here and removed everything not required for "deflate":
// https://github.com/mw99/DataCompression

///
///  DataCompression
///
///  A libcompression wrapper as an extension for the `Data` type
///  (GZIP, ZLIB, LZFSE, LZMA, LZ4, deflate, RFC-1950, RFC-1951, RFC-1952)
///
///  Created by Markus Wanke, 2016/12/05
///

///
///                Apache License, Version 2.0
///
///  Copyright 2016, Markus Wanke
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///

import Compression
import Foundation

extension Data {
    /// Compresses the data using the zlib deflate algorithm.
    /// - returns: raw deflated data according to [RFC-1951](https://tools.ietf.org/html/rfc1951).
    /// - note: Fixed at compression level 5 (best trade off between speed and time)
    func deflate() -> Data? {
        self.withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_ENCODE, algorithm: COMPRESSION_ZLIB)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }
}

fileprivate extension Data {
    func withUnsafeBytes<ResultType, ContentType>(_ body: (UnsafePointer<ContentType>) throws -> ResultType) rethrows -> ResultType {
        try self.withUnsafeBytes({ (rawBufferPointer: UnsafeRawBufferPointer) -> ResultType in
            try body(rawBufferPointer.bindMemory(to: ContentType.self).baseAddress!)
        })
    }
}

private typealias Config = (operation: compression_stream_operation, algorithm: compression_algorithm)

private func perform(_ config: Config, source: UnsafePointer<UInt8>, sourceSize: Int, preload: Data = Data()) -> Data? {
    guard config.operation == COMPRESSION_STREAM_ENCODE || sourceSize > 0 else { return nil }

    let streamBase = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
    defer { streamBase.deallocate() }
    var stream = streamBase.pointee

    let status = compression_stream_init(&stream, config.operation, config.algorithm)
    guard status != COMPRESSION_STATUS_ERROR else { return nil }
    defer { compression_stream_destroy(&stream) }

    var result = preload
    var flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
    let blockLimit = 64 * 1024
    var bufferSize = Swift.max(sourceSize, 64)

    if sourceSize > blockLimit {
        bufferSize = blockLimit
        if config.algorithm == COMPRESSION_LZFSE && config.operation != COMPRESSION_STREAM_ENCODE {
            // This fixes a bug in Apples lzfse decompressor. it will sometimes fail randomly when the input gets
            // splitted into multiple chunks and the flag is not 0. Even though it should always work with FINALIZE...
            flags = 0
        }
    }

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }

    stream.dst_ptr  = buffer
    stream.dst_size = bufferSize
    stream.src_ptr  = source
    stream.src_size = sourceSize

    while true {
        switch compression_stream_process(&stream, flags) {
        case COMPRESSION_STATUS_OK:
            guard stream.dst_size == 0 else { return nil }
            result.append(buffer, count: stream.dst_ptr - buffer)
            stream.dst_ptr = buffer
            stream.dst_size = bufferSize

            if flags == 0 && stream.src_size == 0 { // part of the lzfse bugfix above
                flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
            }

        case COMPRESSION_STATUS_END:
            result.append(buffer, count: stream.dst_ptr - buffer)
            return result

        default:
            return nil
        }
    }
}
