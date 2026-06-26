// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-bit-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-bit-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Bit.Pattern {
    /// Query the **set** (one) bits of a carrier word: first, last, rank, select, scan.
    ///
    /// The word-level succinct-data-structures kernel — population `rank` and
    /// position `select` over the set bits of a single fixed-width word
    /// (Jacobson 1989; Vigna 2008). Dual to ``Zeros``.
    ///
    /// Positions are LSB-indexed (bit 0 = least significant). All operations are
    /// well-defined within the ring Z/2^w where `w = Carrier.bitWidth`.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// Bit.Pattern<UInt64>.Ones(word).first         // 2
    /// Bit.Pattern<UInt64>.Ones(word).rank(below: 4) // 2
    /// Bit.Pattern<UInt64>.Ones(word).select(1)      // 3
    /// ```
    public struct Ones: Sendable {
        @usableFromInline
        let word: Carrier

        /// Wraps a raw word, viewing its set bits.
        @inlinable
        public init(_ word: Carrier) {
            self.word = word
        }
    }
}

// MARK: - First / Last

extension Bit.Pattern.Ones {
    /// Position of the lowest set bit, or `nil` if the word is zero.
    @inlinable
    public var first: Int? {
        word == 0 ? nil : word.trailingZeroBitCount
    }

    /// Position of the highest set bit, or `nil` if the word is zero.
    @inlinable
    public var last: Int? {
        word == 0 ? nil : Carrier.bitWidth - 1 - word.leadingZeroBitCount
    }
}

// MARK: - Rank

extension Bit.Pattern.Ones {
    /// Count of set bits strictly below `position`.
    ///
    /// `rank(below: 0) == 0`; `rank(below: bitWidth) == popcount`. Positions
    /// outside `0...bitWidth` are clamped. The prefix mask is the canonical
    /// `Bit.Pattern.Mask.lowBits` — the single source of mask truth.
    @inlinable
    public func rank(below position: Int) -> Int {
        guard position > 0 else { return 0 }
        guard position < Carrier.bitWidth else { return word.nonzeroBitCount }
        let mask = Bit.Pattern<Carrier>.Mask.lowBits(position).underlying
        return (word & mask).nonzeroBitCount
    }
}

// MARK: - Select

extension Bit.Pattern.Ones {
    /// Position of the `n`th set bit (0-indexed), or `nil` if fewer than
    /// `n + 1` bits are set.
    ///
    /// Dual of ``rank(below:)``; broadword selection via successive
    /// lowest-bit clearing.
    @inlinable
    public func select(_ n: Int) -> Int? {
        guard n >= 0 else { return nil }
        var remaining = n
        var w = word
        while w != 0 {
            if remaining == 0 { return w.trailingZeroBitCount }
            w &= w &- 1
            remaining &-= 1
        }
        return nil
    }
}

// MARK: - Iteration

extension Bit.Pattern.Ones {
    /// Calls `body` for each set-bit position (LSB-first) using the
    /// Wegner/Kernighan `w &= w - 1` technique.
    ///
    /// Complexity: O(popcount).
    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        var w = word
        while w != 0 {
            body(w.trailingZeroBitCount)
            w &= w &- 1
        }
    }
}
