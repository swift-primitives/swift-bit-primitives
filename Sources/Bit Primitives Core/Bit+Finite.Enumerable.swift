//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

// MARK: - Finite.Enumerable

extension Bit: Finite.Enumerable {
    /// Number of bit values.
    @inlinable
    public static var count: Cardinal { Cardinal(2) }

    /// Ordinal of this value (0: zero, 1: one).
    @inlinable
    public var ordinal: Ordinal { Ordinal(UInt(rawValue)) }

    /// Creates a value from its ordinal without bounds checking.
    ///
    /// - Parameter __unchecked: Marker parameter indicating unchecked access.
    /// - Parameter ordinal: Must be 0 (zero) or 1 (one).
    @inlinable
    public init(__unchecked: Void, ordinal: Ordinal) {
        self = Self(rawValue: UInt8(truncatingIfNeeded: ordinal.rawValue))!
    }
}
