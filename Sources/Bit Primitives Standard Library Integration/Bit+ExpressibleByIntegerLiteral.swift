//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

// MARK: - ExpressibleByIntegerLiteral

extension Bit: ExpressibleByIntegerLiteral {
    /// Creates a bit from an integer literal.
    ///
    /// ```swift
    /// let a: Bit = 1  // .one
    /// let b: Bit = 0  // .zero
    /// ```
    ///
    /// - Precondition: Value must be 0 or 1.
    @inlinable
    public init(integerLiteral value: UInt8) {
        precondition(value <= 1, "Bit literal must be 0 or 1")
        self = value == 0 ? .zero : .one
    }
}
