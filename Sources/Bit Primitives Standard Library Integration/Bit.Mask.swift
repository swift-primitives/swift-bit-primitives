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

// MARK: - Bit.Mask

extension Bit {
    /// Accessor namespace for constructing bitmasks over a machine word.
    ///
    /// Reached via the static `.mask` property on unsigned fixed-width integers:
    ///
    /// ```swift
    /// UInt64.mask.prefix(count: 4)  // 0b1111
    /// UInt64.mask.prefix(count: 0)  // 0
    /// ```
    @frozen
    public struct Mask<Word: FixedWidthInteger & UnsignedInteger & Sendable>: Sendable {
        @inlinable
        init() {}
    }
}

// MARK: - Prefix

extension Bit.Mask {
    /// A mask with the lowest `count` bits set.
    ///
    /// Returns `0` when `count` is 0, and `~0` when `count >= bitWidth`.
    ///
    /// ```swift
    /// UInt64.mask.prefix(count: 4)  // 0b1111
    /// UInt64.mask.prefix(count: 0)  // 0
    /// ```
    @inlinable
    public func prefix(count: Int) -> Word {
        guard count > 0 else { return 0 }
        guard count < Word.bitWidth else { return ~0 }
        return (1 << count) &- 1
    }
}

// MARK: - FixedWidthInteger Accessor

extension FixedWidthInteger where Self: UnsignedInteger & Sendable {
    /// Accessor for bitmask construction.
    ///
    /// ```swift
    /// UInt64.mask.prefix(count: 4)  // 0b1111
    /// ```
    @inlinable
    public static var mask: Bit.Mask<Self> {
        Bit.Mask()
    }
}
