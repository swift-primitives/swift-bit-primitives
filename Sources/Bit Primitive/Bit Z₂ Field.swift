// Bit Z₂ Field.swift
// GF(2) field operations: addition (XOR) and multiplication (AND).
//
// Native single-bit algebra — part of the Bit atom's zero-dependency surface
// (relocated from the umbrella, where it had no business needing the umbrella's
// Comparison/Equation/Hash dependencies: it composes only `^` and `&`).

// MARK: - Z₂ Field Operations

extension Bit {
    /// Returns the Z₂ field sum (XOR) of two bits.
    ///
    /// Equivalent to `lhs ^ rhs`.
    @inlinable
    public static func adding(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs ^ rhs
    }

    /// Returns the Z₂ field sum (XOR) of this bit and another.
    ///
    /// Equivalent to `self ^ other`.
    @inlinable
    public func adding(_ other: Bit) -> Bit {
        Self.adding(self, other)
    }

    /// Returns the Z₂ field product (AND) of two bits.
    ///
    /// Equivalent to `lhs & rhs`.
    @inlinable
    public static func multiplying(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs & rhs
    }

    /// Returns the Z₂ field product (AND) of this bit and another.
    ///
    /// Equivalent to `self & other`.
    @inlinable
    public func multiplying(_ other: Bit) -> Bit {
        Self.multiplying(self, other)
    }
}
