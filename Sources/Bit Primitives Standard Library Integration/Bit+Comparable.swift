// Bit+Comparable.swift
// Extends Bit to conform to Swift.Comparable.

// MARK: - Comparable

extension Bit: Swift.Comparable {
    @inlinable
    public static func < (lhs: Bit, rhs: Bit) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
