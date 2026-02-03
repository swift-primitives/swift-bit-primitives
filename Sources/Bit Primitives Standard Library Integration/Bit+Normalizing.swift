// Bit+Normalizing.swift
// Practical initializers for extracting bits from machine words.

import Bit_Primitives_Core

extension Bit {
    /// Normalizing init — any nonzero becomes `.one`.
    ///
    /// Use for bulk extraction from packed words where the value
    /// is known to be a single masked bit (0 or nonzero).
    @inlinable
    public init(normalizing value: UInt8) {
        self = value == 0 ? .zero : .one
    }

    /// XOR with integer (for `bit ^ 1` idiom).
    @inlinable
    public static func ^ (lhs: Bit, rhs: UInt8) -> Bit {
        Bit(normalizing: lhs.rawValue ^ (rhs & 1))
    }
}
