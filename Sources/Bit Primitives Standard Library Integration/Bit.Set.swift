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

import Bit_Primitives_Core

// MARK: - Bit.Set

extension Bit {
    /// Accessor namespace for operations on set bits within a machine word.
    ///
    /// Reached via the `.set` property on unsigned fixed-width integers:
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.set.first     // 2
    /// word.set.last      // 7
    /// word.set.select(0) // 2
    /// word.set.rank(below: 4) // 2
    /// word.set.forEach { print($0) } // 2, 3, 5, 7
    /// ```
    @frozen
    public struct Set<Word: FixedWidthInteger & UnsignedInteger & Sendable>: Sendable {
        @usableFromInline
        let word: Word

        @inlinable
        init(word: Word) {
            self.word = word
        }
    }
}

// MARK: - First / Last

extension Bit.Set {
    /// Index of the lowest set bit, or `nil` if zero.
    ///
    /// Semantic wrapper for `trailingZeroBitCount`.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1000
    /// word.set.first  // 3
    /// UInt64.zero.set.first  // nil
    /// ```
    @inlinable
    public var first: Int? {
        word == 0 ? nil : word.trailingZeroBitCount
    }

    /// Index of the highest set bit, or `nil` if zero.
    ///
    /// Semantic wrapper for `bitWidth - 1 - leadingZeroBitCount`.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1000
    /// word.set.last  // 7
    /// UInt64.zero.set.last  // nil
    /// ```
    @inlinable
    public var last: Int? {
        word == 0 ? nil : Word.bitWidth - 1 - word.leadingZeroBitCount
    }
}

// MARK: - Rank

extension Bit.Set {
    /// Population count of set bits strictly below the given position.
    ///
    /// `rank(below: 0)` is always 0. `rank(below: bitWidth)` equals
    /// `nonzeroBitCount`. Positions outside `0...bitWidth` are clamped.
    ///
    /// This is the foundational primitive for succinct bitvectors
    /// (Jacobson 1989).
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.set.rank(below: 4)  // 2 (bits 2 and 3 are set)
    /// ```
    @inlinable
    public func rank(below position: Int) -> Int {
        guard position > 0 else { return 0 }
        guard position < Word.bitWidth else { return word.nonzeroBitCount }
        let mask = Word.mask.prefix(count: position)
        return (word & mask).nonzeroBitCount
    }
}

// MARK: - Select

extension Bit.Set {
    /// Position of the `n`th set bit (0-indexed), or `nil` if fewer than
    /// `n + 1` bits are set.
    ///
    /// Dual of `rank`. Uses broadword selection via successive bit clearing.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.set.select(0)  // 2 (first set bit)
    /// word.set.select(1)  // 3 (second set bit)
    /// word.set.select(4)  // nil (only 4 set bits total)
    /// ```
    @inlinable
    public func select(_ n: Int) -> Int? {
        guard n >= 0 else { return nil }
        var remaining = n
        var w = word
        while w != 0 {
            if remaining == 0 {
                return w.trailingZeroBitCount
            }
            w &= w &- 1
            remaining &-= 1
        }
        return nil
    }
}

// MARK: - Iteration

extension Bit.Set {
    /// Calls `body` for each set bit position using the Wegner/Kernighan
    /// technique (`word &= word - 1`).
    ///
    /// - Complexity: O(popcount) — only visits set bits.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.set.forEach { print($0) }  // 2, 3, 5, 7
    /// ```
    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        var w = word
        while w != 0 {
            body(w.trailingZeroBitCount)
            w &= w &- 1
        }
    }
}

// MARK: - FixedWidthInteger Accessor

extension FixedWidthInteger where Self: UnsignedInteger & Sendable {
    /// Accessor for operations on set bits within this word.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.set.first  // 2
    /// word.set.forEach { print($0) }  // 2, 3, 5, 7
    /// ```
    @inlinable
    public var set: Bit.Set<Self> {
        Bit.Set(word: self)
    }
}
