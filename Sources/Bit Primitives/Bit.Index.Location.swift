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
    /// When bits are packed into fixed-width integer words, `Location` provides
    /// the computed word index, bit offset, and mask needed for read/write operations.
    ///
    /// The type is generic over the word type, allowing use with any storage:
    /// - `Location<UInt>` for standard word-sized storage
    /// - `Location<UInt8>` for byte-packed storage
    /// - `Location<UInt32>` for 32-bit word storage
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let index: Bit.Index = 42
    /// let loc = Bit.Index.Location<UInt>(index: index, bitsPerWord: .bitsPerWord)
    /// let bit = (words[loc.word] & loc.mask) != 0
    /// ```
    public struct Location<Word: FixedWidthInteger & UnsignedInteger & Sendable>: Sendable {
        /// The word index in the storage array.
        public let word: Index<Word>

        /// The bit offset within the word (0..<Word.bitWidth).
        public let bit: Index<Bit>.Offset

        /// The bitmask for this bit position: `1 << bit`.
        public let mask: Word

        /// Creates a location from precomputed values.
        @inlinable
        public init(word: Index<Word>, bit: Index<Bit>.Offset, mask: Word) {
            self.word = word
            self.bit = bit
            self.mask = mask
        }

        /// Creates a location from precomputed word and bit indices.
        @inlinable
        public init(word: Index<Word>, bit: Index<Bit>.Offset) {
            self.word = word
            self.bit = bit
            self.mask = Word(1) << bit.rawValue.rawValue
        }

        /// Creates a location from a typed bit index.
        ///
        /// - Parameters:
        ///   - index: The bit index to locate.
        ///   - bitsPerWord: The ratio of bits per word for the storage type.
        @inlinable
        public init(
            index: Bit.Index,
            bitsPerWord: Affine.Discrete.Ratio<Word, Bit>
        ) {
            let i = Int(index.position.rawValue)
            let factor = bitsPerWord.factor

            self.word = Index<Word>(__unchecked: (), Ordinal.Position(UInt(i / factor)))

            let bitOffset = i % factor
            self.bit = Index<Bit>.Offset(Affine.Discrete.Vector(bitOffset))
            self.mask = Word(1) << bitOffset
        }

        /// Creates a location from a typed bit count.
        ///
        /// Use this when computing the location for append/remove operations
        /// where you have the count rather than an index.
        ///
        /// - Parameters:
        ///   - count: The bit count (used as position).
        ///   - bitsPerWord: The ratio of bits per word for the storage type.
        @inlinable
        public init(
            count: Bit.Index.Count,
            bitsPerWord: Affine.Discrete.Ratio<Word, Bit>
        ) {
            let i = Int(count.count.rawValue)
            let factor = bitsPerWord.factor

            self.word = Index<Word>(__unchecked: (), Ordinal.Position(UInt(i / factor)))

            let bitOffset = i % factor
            self.bit = Index<Bit>.Offset(Affine.Discrete.Vector(bitOffset))
            self.mask = Word(1) << bitOffset
        }
    }

    /// Computes the location of this bit index within word-based storage.
    ///
    /// - Parameter bitsPerWord: The ratio of bits per word for the storage type.
    /// - Returns: The word index, bit offset, and mask for this bit position.
    @inlinable
    public func location<Word: FixedWidthInteger & UnsignedInteger & Sendable>(
        bitsPerWord: Affine.Discrete.Ratio<Word, Bit>
    ) -> Location<Word> {
        Location<Word>(index: self, bitsPerWord: bitsPerWord)
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
    public init(_ byteIndex: Index_Primitives.Index<UInt8>, bitOffset: Index<Bit>.Offset) {
        // Scale byte offset to bit offset, then add bit offset within byte
        let byteAsOffset = Index<UInt8>.Offset(Affine.Discrete.Vector(Int(byteIndex.position.rawValue)))
        let baseBitOffset = byteAsOffset * .bitsPerByte
        let totalBitOffset = baseBitOffset.rawValue.rawValue + bitOffset.rawValue.rawValue
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
    /// let storage = Bit.Index.Storage<UInt>(count: count, bitsPerWord: .bitsPerWord)
    /// let words = ContiguousArray<UInt>(repeating: 0, count: storage.wordCount)
    /// ```
    public struct Storage<Word: FixedWidthInteger & UnsignedInteger & Sendable>: Sendable {
        /// The number of words needed to store the bits.
        public let wordCount: Index<Word>.Count

        /// The number of unused bits in the last word (0..<Word.bitWidth).
        public let unusedBits: Index<Bit>.Count

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
            let c = Int(count.count.rawValue)
            let factor = bitsPerWord.factor
            let words = (c + factor - 1) / factor
            let unused = words * factor - c

            self.wordCount = Index<Word>.Count(Cardinal.Count(UInt(words)))
            self.unusedBits = Index<Bit>.Count(Cardinal.Count(UInt(unused)))
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
            let c = Int(capacity.count.rawValue)
            let factor = bitsPerWord.factor
            let words = (c + factor - 1) / factor
            let unused = words * factor - c

            self.wordCount = Index<Word>.Count(Cardinal.Count(UInt(words)))
            self.unusedBits = Index<Bit>.Count(Cardinal.Count(UInt(unused)))
        }
    }
}
