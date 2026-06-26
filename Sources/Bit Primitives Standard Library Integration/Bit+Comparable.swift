// Bit+Comparable.swift
// Extends Bit to conform to Swift.Comparable.

// MARK: - Comparable

extension Bit: Swift.Comparable {
    /// Returns whether `lhs` orders before `rhs` (`.zero` before `.one`).
    @inlinable
    public static func < (lhs: Bit, rhs: Bit) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
