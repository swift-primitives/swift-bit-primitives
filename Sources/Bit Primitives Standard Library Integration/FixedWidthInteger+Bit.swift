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

// MARK: - Bit Rotation

extension FixedWidthInteger {
    /// Rotates bits left by the specified count.
    ///
    /// Performs a circular left shift, preserving all bits. Unlike a standard left shift
    /// which fills vacated positions with zeros, rotation wraps bits from the left end
    /// to the right end.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt8 = 0b11010011  // Binary: 11010011
    /// let rotated = UInt8.rotateLeft(x, by: 2)
    /// // 0b01001111  // Binary: 01001111
    /// ```
    ///
    /// - Parameters:
    ///   - value: The value to rotate
    ///   - count: Number of positions to rotate left
    /// - Returns: The value with bits rotated left
    @inlinable
    public static func rotateLeft(_ value: Self, by count: Int) -> Self {
        let shift = count % Self.bitWidth
        guard shift != 0 else { return value }

        return (value << shift) | (value >> (Self.bitWidth - shift))
    }

    /// Rotates bits left by the specified count.
    ///
    /// Performs a circular left shift, preserving all bits. Unlike a standard left shift
    /// which fills vacated positions with zeros, rotation wraps bits from the left end
    /// to the right end.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt8 = 0b11010011  // Binary: 11010011
    /// let rotated = x.rotateLeft(by: 2)
    /// // 0b01001111  // Binary: 01001111
    /// ```
    ///
    /// - Parameter count: Number of positions to rotate left
    /// - Returns: The value with bits rotated left
    @inlinable
    public func rotateLeft(by count: Int) -> Self {
        Self.rotateLeft(self, by: count)
    }

    /// Rotates bits right by the specified count.
    ///
    /// Performs a circular right shift, preserving all bits. Unlike a standard right shift
    /// which fills vacated positions with zeros or sign bits, rotation wraps bits from
    /// the right end to the left end.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt8 = 0b11010011  // Binary: 11010011
    /// let rotated = UInt8.rotateRight(x, by: 2)
    /// // 0b11110100  // Binary: 11110100
    /// ```
    ///
    /// - Parameters:
    ///   - value: The value to rotate
    ///   - count: Number of positions to rotate right
    /// - Returns: The value with bits rotated right
    @inlinable
    public static func rotateRight(_ value: Self, by count: Int) -> Self {
        let shift = count % Self.bitWidth
        guard shift != 0 else { return value }

        return (value >> shift) | (value << (Self.bitWidth - shift))
    }

    /// Rotates bits right by the specified count.
    ///
    /// Performs a circular right shift, preserving all bits. Unlike a standard right shift
    /// which fills vacated positions with zeros or sign bits, rotation wraps bits from
    /// the right end to the left end.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt8 = 0b11010011  // Binary: 11010011
    /// let rotated = x.rotateRight(by: 2)
    /// // 0b11110100  // Binary: 11110100
    /// ```
    ///
    /// - Parameter count: Number of positions to rotate right
    /// - Returns: The value with bits rotated right
    @inlinable
    public func rotateRight(by count: Int) -> Self {
        Self.rotateRight(self, by: count)
    }

    /// Reverses the order of all bits.
    ///
    /// Reflects the bit pattern, swapping bit positions from ends to middle.
    /// Useful in FFT algorithms, cryptography, and binary protocol implementations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt8 = 0b11010011  // Binary: 11010011
    /// let reversed = UInt8.reverseBits(x)
    /// // 0b11001011  // Binary: 11001011
    /// ```
    ///
    /// - Parameter value: The value to reverse
    /// - Returns: The value with all bits in reversed order
    @inlinable
    public static func reverseBits(_ value: Self) -> Self {
        var result: Self = 0
        var workingValue = value

        for _ in 0..<Self.bitWidth {
            result <<= 1
            result |= workingValue & 1
            workingValue >>= 1
        }

        return result
    }

    /// Reverses the order of all bits.
    ///
    /// Reflects the bit pattern, swapping bit positions from ends to middle.
    /// Useful in FFT algorithms, cryptography, and binary protocol implementations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt8 = 0b11010011  // Binary: 11010011
    /// let reversed = x.reverseBits()
    /// // 0b11001011  // Binary: 11001011
    /// ```
    ///
    /// - Returns: The value with all bits in reversed order
    @inlinable
    public func reverseBits() -> Self {
        Self.reverseBits(self)
    }
}
