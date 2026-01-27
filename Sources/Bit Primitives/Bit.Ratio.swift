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

// MARK: - Bit/Byte Conversion Ratio

extension Affine.Discrete.Ratio where From == UInt8, To == Bit {
    /// The number of bits per byte (8).
    ///
    /// This is the canonical ratio for converting between byte and bit domains.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let byteOffset = Index<UInt8>.Offset(2)
    /// let bitOffset = byteOffset * .bitsPerByte  // Index<Bit>.Offset(16)
    ///
    /// let byteCount = Index<UInt8>.Count(Cardinal.Count(10))
    /// let bitCount = byteCount * .bitsPerByte  // Index<Bit>.Count(80)
    /// ```
    @inlinable
    public static var bitsPerByte: Self { Self.init(8) }
}
