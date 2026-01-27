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

public import Affine_Primitives
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

        /// Creates a location from a typed bit index.
        ///
        /// - Parameters:
        ///   - index: The bit index to locate.
        ///   - bitsPerWord: The number of bits per storage word (typically `UInt.bitWidth`).
        @inlinable
        public init(index: Bit.Index, bitsPerWord: Int) {
            let i = Int(index.position.rawValue)
            self.word = i / bitsPerWord
            self.bit = i % bitsPerWord
            self.mask = 1 << self.bit
        }

        /// Creates a location from a typed bit count.
        ///
        /// Use this when computing the location for append/remove operations
        /// where you have the count rather than an index.
        ///
        /// - Parameters:
        ///   - count: The bit count (used as position).
        ///   - bitsPerWord: The number of bits per storage word (typically `UInt.bitWidth`).
        @inlinable
        public init(count: Bit.Index.Count, bitsPerWord: Int) {
            let i = Int(count.count.rawValue)
            self.word = i / bitsPerWord
            self.bit = i % bitsPerWord
            self.mask = 1 << self.bit
        }
    }

    /// Computes the location of this bit index within word-based storage.
    ///
    /// - Parameter bitsPerWord: The number of bits per storage word (typically `UInt.bitWidth`).
    /// - Returns: The word index, bit offset, and mask for this bit position.
    @inlinable
    public func location(bitsPerWord: Int) -> Location {
        Location(index: self, bitsPerWord: bitsPerWord)
    }

    /// Creates a bit index from a byte index (first bit of that byte).
    ///
    /// Converts a byte-aligned position to the corresponding bit position.
    /// Byte 0 → Bit 0, Byte 1 → Bit 8, etc.
    ///
    /// This uses the affine decomposition: convert position to offset from
    /// origin, scale, then translate back. This is mathematically correct
    /// because positions cannot be scaled directly in affine geometry.
    ///
    /// - Parameter index: The byte index to convert.
    @inlinable
    public init(_ byteIndex: Index_Primitives.Index<UInt8>) {
        // Affine decomposition: position as offset from origin, scale, translate back
        let byteOffset = Index<UInt8>.Offset(Affine.Discrete.Vector(Int(byteIndex.position.rawValue)))
        let bitOffset = byteOffset * .bitsPerByte
        self.init(__unchecked: (), Ordinal.Position(UInt(bitOffset.rawValue.rawValue)))
    }

    /// Creates a bit index from a byte index and bit offset within that byte.
    ///
    /// - Parameters:
    ///   - byteIndex: The byte index.
    ///   - bitOffset: The bit offset within the byte (0..<8).
    @inlinable
    public init(_ byteIndex: Index_Primitives.Index<UInt8>, bitOffset: Int) {
        // Scale byte offset to bit offset, then add bit offset within byte
        let byteAsOffset = Index<UInt8>.Offset(Affine.Discrete.Vector(Int(byteIndex.position.rawValue)))
        let baseBitOffset = byteAsOffset * .bitsPerByte
        let totalBitOffset = baseBitOffset.rawValue.rawValue + bitOffset
        self.init(__unchecked: (), Ordinal.Position(UInt(totalBitOffset)))
    }

    /// Storage requirements for a bit count in word-based storage.
    ///
    /// Computes the number of words needed and unused bits in the last word
    /// for storing a given number of bits.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let count: Bit.Index.Count = 100
    /// let storage = Bit.Index.Storage(count: count, bitsPerWord: UInt.bitWidth)
    /// let words = ContiguousArray<UInt>(repeating: 0, count: storage.wordCount)
    /// ```
    public struct Storage: Sendable {
        /// The number of words needed to store the bits.
        public let wordCount: Int

        /// The number of unused bits in the last word (0..<bitsPerWord).
        public let unusedBits: Int

        /// Creates storage requirements from a bit count.
        ///
        /// - Parameters:
        ///   - count: The number of bits to store.
        ///   - bitsPerWord: The number of bits per storage word (typically `UInt.bitWidth`).
        @inlinable
        public init(count: Bit.Index.Count, bitsPerWord: Int) {
            let c = Int(count.count.rawValue)
            self.wordCount = (c + bitsPerWord - 1) / bitsPerWord
            self.unusedBits = wordCount * bitsPerWord - c
        }

        /// Creates storage requirements from a capacity.
        ///
        /// - Parameters:
        ///   - capacity: The bit capacity.
        ///   - bitsPerWord: The number of bits per storage word (typically `UInt.bitWidth`).
        @inlinable
        public init(capacity: Bit.Index.Count, bitsPerWord: Int) {
            let c = Int(capacity.count.rawValue)
            self.wordCount = (c + bitsPerWord - 1) / bitsPerWord
            self.unusedBits = wordCount * bitsPerWord - c
        }
    }
}
