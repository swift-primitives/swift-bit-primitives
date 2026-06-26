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
        // operands ∈ {0,1}; `^` stays in {0,1}, so `Bit(rawValue:)` is total (never nil).
        // swift-format-ignore: NeverForceUnwrap
        Bit(rawValue: lhs.rawValue ^ rhs.rawValue)!
    }

    /// AND (multiplication in Z₂).
    @inlinable
    public static func & (lhs: Bit, rhs: Bit) -> Bit {
        // operands ∈ {0,1}; `&` stays in {0,1}, so `Bit(rawValue:)` is total (never nil).
        // swift-format-ignore: NeverForceUnwrap
        Bit(rawValue: lhs.rawValue & rhs.rawValue)!
    }

    /// OR.
    @inlinable
    public static func | (lhs: Bit, rhs: Bit) -> Bit {
        // operands ∈ {0,1}; `|` stays in {0,1}, so `Bit(rawValue:)` is total (never nil).
        // swift-format-ignore: NeverForceUnwrap
        Bit(rawValue: lhs.rawValue | rhs.rawValue)!
    }

    /// Bitwise NOT (flip).
    @inlinable
    public static prefix func ~ (value: Bit) -> Bit {
        // flipping a Bit (`rawValue ^ 1`) stays in {0,1}, so `Bit(rawValue:)` is total (never nil).
        // swift-format-ignore: NeverForceUnwrap
        Bit(rawValue: value.rawValue ^ 1)!
    }
}
