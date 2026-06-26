// Bit.Order+CaseIterable.swift
// Extends Bit.Order to conform to Swift.CaseIterable.

import Bit_Primitive

extension Bit.Order: CaseIterable {
    /// All bit order values: `[.msb, .lsb]`.
    public static let allCases: [Bit.Order] = [.msb, .lsb]
}
