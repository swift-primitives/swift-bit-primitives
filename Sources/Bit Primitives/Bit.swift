// Bit.swift

public import Algebra_Primitives

/// Binary digit: zero or one.
///
/// The fundamental unit of information in digital systems. Forms the Z₂ field
/// under XOR (addition) and AND (multiplication). Use `Bit` when working with
/// individual binary digits, flags, or boolean algebra.
///
/// ## Example
///
/// ```swift
/// let a: Bit = .one
/// let b: Bit = .zero
/// print(a.flipped)       // Bit(0)
/// print(a.xor(b))        // Bit(1)
/// print(Bit(true))       // Bit(1)
/// ```
///
/// ## Arrays
///
/// Use `[Bit]` for simple unpacked arrays, or `Array<Bit>.Packed` for
/// space-efficient packed storage (8x compression).
///
/// ```swift
/// // Unpacked: 1 byte per bit
/// var simple: [Bit] = [true, false, true]
///
/// // Packed: 1 bit per bit (in swift-array-primitives)
/// var packed = Array<Bit>.Packed(simple)
/// ```
public struct Bit: Sendable, Hashable, Equatable {
    /// The underlying storage (0 or 1).
    @usableFromInline
    let rawValue: UInt8

    /// Creates a bit from a raw value.
    ///
    /// - Parameter rawValue: Must be 0 or 1.
    /// - Precondition: `rawValue` must be 0 or 1.
    @inlinable
    public init(rawValue: UInt8) {
        precondition(rawValue <= 1, "Bit rawValue must be 0 or 1")
        self.rawValue = rawValue
    }

    /// Unchecked initializer for internal use.
    @inlinable
    init(__unchecked rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

// MARK: - Static Constants

extension Bit {
    /// Binary zero (false, off, low).
    public static let zero = Bit(__unchecked: 0)

    /// Binary one (true, on, high).
    public static let one = Bit(__unchecked: 1)
}

// MARK: - CaseIterable

extension Bit: CaseIterable {
    /// All bit values: `[.zero, .one]`.
    public static let allCases: [Bit] = [.zero, .one]
}

// MARK: - Comparable

extension Bit: Comparable {
    @inlinable
    public static func < (lhs: Bit, rhs: Bit) -> Bool {
        lhs.rawValue < rhs.rawValue
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
        self.rawValue = value ? 1 : 0
    }
}

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
        self.rawValue = value
    }
}

// MARK: - Boolean Conversion

extension Bit {
    /// Creates a bit from a boolean (`true` → `.one`, `false` → `.zero`).
    @inlinable
    public init(_ bool: Bool) {
        self.rawValue = bool ? 1 : 0
    }

    /// Boolean representation (`true` if `.one`, `false` if `.zero`).
    @inlinable
    public var boolValue: Bool {
        rawValue != 0
    }
}

// MARK: - Bitwise Operators

extension Bit {
    /// XOR (addition in Z₂).
    @inlinable
    public static func ^ (lhs: Bit, rhs: Bit) -> Bit {
        Bit(__unchecked: lhs.rawValue ^ rhs.rawValue)
    }

    /// XOR with integer (for `bit ^ 1` idiom).
    @inlinable
    public static func ^ (lhs: Bit, rhs: UInt8) -> Bit {
        Bit(__unchecked: lhs.rawValue ^ rhs)
    }

    /// AND (multiplication in Z₂).
    @inlinable
    public static func & (lhs: Bit, rhs: Bit) -> Bit {
        Bit(__unchecked: lhs.rawValue & rhs.rawValue)
    }

    /// OR.
    @inlinable
    public static func | (lhs: Bit, rhs: Bit) -> Bit {
        Bit(__unchecked: lhs.rawValue | rhs.rawValue)
    }

    /// Bitwise NOT (flip).
    @inlinable
    public static prefix func ~ (value: Bit) -> Bit {
        value ^ 1
    }
}

// MARK: - Flip / Toggle

extension Bit {
    /// Flipped bit (NOT operation: 0→1, 1→0).
    @inlinable
    public static func flipped(_ bit: Bit) -> Bit {
        bit ^ 1
    }

    /// Flipped bit (NOT operation: 0→1, 1→0).
    @inlinable
    public var flipped: Bit {
        self ^ 1
    }

    /// Returns the flipped bit (logical NOT).
    @inlinable
    public static prefix func ! (value: Bit) -> Bit {
        value ^ 1
    }

    /// Toggled bit (digital logic terminology).
    @inlinable
    public static func toggled(_ bit: Bit) -> Bit {
        bit ^ 1
    }

    /// Toggled bit (digital logic terminology).
    @inlinable
    public var toggled: Bit {
        self ^ 1
    }
}

// MARK: - Boolean Operations (Method Style)

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

// MARK: - CustomStringConvertible

extension Bit: CustomStringConvertible {
    public var description: String {
        rawValue == 0 ? "0" : "1"
    }
}

// MARK: - Tagged Value

extension Bit {
    /// A value paired with a bit flag.
    public typealias Value<Payload> = Pair<Bit, Payload>
}
