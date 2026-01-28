//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2026.
//

import Index_Primitives

extension Bit {
    /// Storage requirements for a bit count in word-based storage.
    ///
    /// Computes the number of words needed and unused bits in the last word
    /// for storing a given number of bits.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let count: Bit.Index.Count = 100
    /// let storage = Bit.Index.Storage<UInt>(count: count, bitsPerWord: .bitsPerWord)
    /// let words = ContiguousArray<UInt>(repeating: 0, count: storage.wordCount)
    /// ```
    public struct Storage<Word: FixedWidthInteger & UnsignedInteger & Sendable>: Sendable {
        /// The number of words needed to store the bits.
        public let wordCount: Index_Primitives.Index<Word>.Count

        /// The number of unused bits in the last word (0..<Word.bitWidth).
        public let unusedBits: Bit.Index.Count

        /// Creates storage requirements from a bit count.
        ///
        /// - Parameters:
        ///   - count: The number of bits to store.
        ///   - bitsPerWord: The ratio of bits per word for the storage type.
        @inlinable
        public init(
            count: Bit.Index.Count,
            bitsPerWord: Affine.Discrete.Ratio<Word, Bit>
        ) {
            let c = Int(count.count)
            let factor = bitsPerWord.factor
            let words = (c + factor - 1) / factor
            let unused = words * factor - c

            self.wordCount = Index_Primitives.Index<Word>.Count(Cardinal(UInt(words)))
            self.unusedBits = Index_Primitives.Index<Bit>.Count(Cardinal(UInt(unused)))
        }

        /// Creates storage requirements from a capacity.
        ///
        /// - Parameters:
        ///   - capacity: The bit capacity.
        ///   - bitsPerWord: The ratio of bits per word for the storage type.
        @inlinable
        public init(
            capacity: Bit.Index.Count,
            bitsPerWord: Affine.Discrete.Ratio<Word, Bit>
        ) {
            let c = Int(capacity.count)
            let factor = bitsPerWord.factor
            let words = (c + factor - 1) / factor
            let unused = words * factor - c

            self.wordCount = Index_Primitives.Index<Word>.Count(Cardinal(UInt(words)))
            self.unusedBits = Bit.Index.Count(Cardinal(UInt(unused)))
        }
    }
}
