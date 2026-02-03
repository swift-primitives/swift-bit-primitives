//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

extension Bit {
    /// XOR (addition in Z₂).
    @inlinable
    public static func ^ (lhs: Bit, rhs: Bit) -> Bit {
        Bit(rawValue: lhs.rawValue ^ rhs.rawValue)!
    }

    /// AND (multiplication in Z₂).
    @inlinable
    public static func & (lhs: Bit, rhs: Bit) -> Bit {
        Bit(rawValue: lhs.rawValue & rhs.rawValue)!
    }

    /// OR.
    @inlinable
    public static func | (lhs: Bit, rhs: Bit) -> Bit {
        Bit(rawValue: lhs.rawValue | rhs.rawValue)!
    }

    /// Bitwise NOT (flip).
    @inlinable
    public static prefix func ~ (value: Bit) -> Bit {
        Bit(rawValue: value.rawValue ^ 1)!
    }
}
