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
    /// Query the **clear** (zero) bits of a carrier word: first, last, rank, select, scan.
    ///
    /// The symbol-dual of ``Ones`` — `rank₀` / `select₀` in succinct-data-structures
    /// terms, with the identity `rank₀(i) = i − rank₁(i)`. Implemented over the
    /// complement of the word, so all `Carrier.bitWidth` positions are in scope:
    /// there is no sub-word "logical capacity" at the single-word level (that is a
    /// container concern, e.g. `Bit.Vector`).
    ///
    /// ```swift
    /// let word: UInt8 = 0b1010_1100
    /// Bit.Pattern<UInt8>.Zeros(word).first          // 0
    /// Bit.Pattern<UInt8>.Zeros(word).rank(below: 4)  // 2 (bits 0 and 1 are clear)
    /// ```
    public struct Zeros: Sendable {
        @usableFromInline
        let word: Carrier

        /// Wraps a raw word, viewing its clear bits.
        @inlinable
        public init(_ word: Carrier) {
            self.word = word
        }
    }
}

// MARK: - First / Last

extension Bit.Pattern.Zeros {
    /// Position of the lowest clear bit, or `nil` if every bit is set.
    @inlinable
    public var first: Int? {
        Bit.Pattern<Carrier>.Ones(~word).first
    }

    /// Position of the highest clear bit, or `nil` if every bit is set.
    @inlinable
    public var last: Int? {
        Bit.Pattern<Carrier>.Ones(~word).last
    }
}

// MARK: - Rank

extension Bit.Pattern.Zeros {
    /// Count of clear bits strictly below `position` (`rank₀(i) = i − rank₁(i)`).
    ///
    /// `rank(below: 0) == 0`; `rank(below: bitWidth) == bitWidth − popcount`.
    /// Positions outside `0...bitWidth` are clamped.
    @inlinable
    public func rank(below position: Int) -> Int {
        guard position > 0 else { return 0 }
        let bound = Swift.min(position, Carrier.bitWidth)
        return bound - Bit.Pattern<Carrier>.Ones(word).rank(below: bound)
    }
}

// MARK: - Select

extension Bit.Pattern.Zeros {
    /// Position of the `n`th clear bit (0-indexed), or `nil` if fewer than
    /// `n + 1` bits are clear.
    ///
    /// Dual of ``rank(below:)`` — selection over the complemented word.
    @inlinable
    public func select(_ n: Int) -> Int? {
        Bit.Pattern<Carrier>.Ones(~word).select(n)
    }
}

// MARK: - Iteration

extension Bit.Pattern.Zeros {
    /// Calls `body` for each clear-bit position (LSB-first).
    ///
    /// Complexity: O(zero-count).
    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        Bit.Pattern<Carrier>.Ones(~word).forEach(body)
    }
}
