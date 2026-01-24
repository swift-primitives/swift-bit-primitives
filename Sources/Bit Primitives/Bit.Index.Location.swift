// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Index_Primitives

extension Bit.Index {
    /// A bit's location within word-based storage.
    ///
    /// When bits are packed into `UInt` words, `Location` provides the computed
    /// word index, bit offset, and mask needed for read/write operations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let index: Bit.Index = 42
    /// let loc = index.location(bitsPerWord: UInt.bitWidth)
    /// let bit = (words[loc.word] & loc.mask) != 0
    /// ```
    public struct Location: Sendable {
        /// The word index in the storage array.
        public let word: Int

        /// The bit offset within the word (0..<bitsPerWord).
        public let bit: Int

        /// The bitmask for this bit position: `1 << bit`.
        public let mask: UInt

        /// Creates a location from precomputed values.
        @inlinable
        public init(word: Int, bit: Int, mask: UInt) {
            self.word = word
            self.bit = bit
            self.mask = mask
        }

        /// Creates a location from precomputed word and bit indices.
        @inlinable
        public init(word: Int, bit: Int) {
            self.word = word
            self.bit = bit
            self.mask = 1 << bit
        }
    }

    /// Computes the location of this bit index within word-based storage.
    ///
    /// - Parameter bitsPerWord: The number of bits per storage word (typically `UInt.bitWidth`).
    /// - Returns: The word index, bit offset, and mask for this bit position.
    @inlinable
    public func location(bitsPerWord: Int) -> Location {
        let i = position.rawValue
        let word = i / bitsPerWord
        let bit = i % bitsPerWord
        return Location(word: word, bit: bit)
    }
}
