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

// MARK: - Word-Level Bit Kernels
//
// Operations on set bits within a single machine word.
// These are the building blocks for succinct data structures
// (Jacobson 1989, Vigna 2008) and packed bit containers.

extension FixedWidthInteger where Self: UnsignedInteger & Sendable {

    // MARK: - Prefix Mask

    /// A mask with the lowest `count` bits set.
    ///
    /// Returns `0` when `count` is 0, and `~0` when `count >= bitWidth`.
    ///
    /// ```swift
    /// UInt64.prefixMask(count: 4)  // 0b1111
    /// UInt64.prefixMask(count: 0)  // 0
    /// ```
    @inlinable
    public static func prefixMask(count: Int) -> Self {
        guard count > 0 else { return 0 }
        guard count < bitWidth else { return ~0 }
        return (1 << count) &- 1
    }

    // MARK: - Rank

    /// Population count of set bits strictly below the given position.
    ///
    /// `rank1(below: 0)` is always 0. `rank1(below: bitWidth)` equals
    /// `nonzeroBitCount`. Positions outside `0...bitWidth` are clamped.
    ///
    /// This is the foundational primitive for succinct bitvectors
    /// (Jacobson 1989).
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.rank1(below: 4)  // 2 (bits 2 and 3 are set)
    /// ```
    @inlinable
    public func rank1(below position: Int) -> Int {
        guard position > 0 else { return 0 }
        guard position < Self.bitWidth else { return self.nonzeroBitCount }
        let mask = Self.prefixMask(count: position)
        return (self & mask).nonzeroBitCount
    }

    // MARK: - Select

    /// Position of the `n`th set bit (0-indexed), or `nil` if fewer than
    /// `n + 1` bits are set.
    ///
    /// Dual of `rank1`. Uses broadword selection via successive bit clearing.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.select1(0)  // 2 (first set bit)
    /// word.select1(1)  // 3 (second set bit)
    /// word.select1(4)  // nil (only 4 set bits total)
    /// ```
    @inlinable
    public func select1(_ n: Int) -> Int? {
        guard n >= 0 else { return nil }
        var remaining = n
        var word = self
        while word != 0 {
            if remaining == 0 {
                return word.trailingZeroBitCount
            }
            word &= word &- 1
            remaining &-= 1
        }
        return nil
    }

    // MARK: - First / Last Set Bit

    /// Index of the lowest set bit, or `nil` if zero.
    ///
    /// Semantic wrapper for `trailingZeroBitCount`.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1000
    /// word.firstSetBit  // 3
    /// UInt64.zero.firstSetBit  // nil
    /// ```
    @inlinable
    public var firstSetBit: Int? {
        self == 0 ? nil : self.trailingZeroBitCount
    }

    /// Index of the highest set bit, or `nil` if zero.
    ///
    /// Semantic wrapper for `bitWidth - 1 - leadingZeroBitCount`.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1000
    /// word.lastSetBit  // 7
    /// UInt64.zero.lastSetBit  // nil
    /// ```
    @inlinable
    public var lastSetBit: Int? {
        self == 0 ? nil : Self.bitWidth - 1 - self.leadingZeroBitCount
    }

    // MARK: - Set Bit Iteration

    /// Calls `body` for each set bit position using the Wegner/Kernighan
    /// technique (`word &= word - 1`).
    ///
    /// - Complexity: O(popcount) — only visits set bits.
    ///
    /// ```swift
    /// let word: UInt64 = 0b1010_1100
    /// word.forEachSetBit { print($0) }  // 2, 3, 5, 7
    /// ```
    @inlinable
    public func forEachSetBit(_ body: (Int) -> Void) {
        var word = self
        while word != 0 {
            body(word.trailingZeroBitCount)
            word &= word &- 1
        }
    }
}
