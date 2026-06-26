//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

// MARK: - Boolean Conversion

extension Bit {
    /// Creates a bit from a boolean (`true` → `.one`, `false` → `.zero`).
    @inlinable
    public init(_ bool: Bool) {
        self = bool ? .one : .zero
    }
}

// MARK: - ExpressibleByBooleanLiteral

extension Bit: ExpressibleByBooleanLiteral {
    /// Creates a bit from a boolean literal.
    ///
    /// ```swift
    /// let a: Bit = true   // .one
    /// let b: Bit = false  // .zero
    /// ```
    @inlinable
    public init(booleanLiteral value: Bool) {
        self = value ? .one : .zero
    }
}

extension Bool {
    /// Creates a boolean from a bit (`.one` → `true`, `.zero` → `false`).
    public init(
        _ bit: Bit
    ) {
        self = bit == .one
    }
}
