// Bit Boolean Operations.swift
// Method-style Boolean operations and complement aliases.

// MARK: - Complement Aliases

extension Bit {
    /// Flipped bit (NOT operation: 0→1, 1→0).
    @inlinable
    public static func flipped(_ bit: Bit) -> Bit {
        ~bit
    }

    /// Flipped bit (NOT operation: 0→1, 1→0).
    @inlinable
    public var flipped: Bit {
        ~self
    }

    /// Returns the flipped bit (logical NOT).
    @inlinable
    public static prefix func ! (value: Bit) -> Bit {
        ~value
    }

    /// Toggled bit (digital logic terminology).
    @inlinable
    public static func toggled(_ bit: Bit) -> Bit {
        ~bit
    }

    /// Toggled bit (digital logic terminology).
    @inlinable
    public var toggled: Bit {
        ~self
    }
}

// MARK: - Named Binary Operations

extension Bit {
    /// Logical AND: returns `.one` only if both bits are `.one`.
    @inlinable
    public static func and(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs & rhs
    }

    /// Logical AND: returns `.one` only if both bits are `.one`.
    @inlinable
    public func and(_ other: Bit) -> Bit {
        self & other
    }

    /// Logical OR: returns `.one` if either bit is `.one`.
    @inlinable
    public static func or(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs | rhs
    }

    /// Logical OR: returns `.one` if either bit is `.one`.
    @inlinable
    public func or(_ other: Bit) -> Bit {
        self | other
    }

    /// Logical XOR: returns `.one` if bits differ (addition in Z₂).
    @inlinable
    public static func xor(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs ^ rhs
    }

    /// Logical XOR: returns `.one` if bits differ (addition in Z₂).
    @inlinable
    public func xor(_ other: Bit) -> Bit {
        self ^ other
    }
}
