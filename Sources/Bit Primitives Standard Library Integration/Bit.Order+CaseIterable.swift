// Bit.Order+CaseIterable.swift
// Extends Bit.Order to conform to Swift.CaseIterable.

import Bit_Primitives_Core

extension Bit.Order: CaseIterable {
    /// All bit order values: `[.msb, .lsb]`.
    public static let allCases: [Bit.Order] = [.msb, .lsb]
}
