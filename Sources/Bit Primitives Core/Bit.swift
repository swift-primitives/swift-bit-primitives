// Bit.swift

// MARK: - Design Doctrine
//
// Bit is a semantic binary digit (Z₂ field element), not a storage unit.
// Memory density guarantees exist only on packed containers:
// - Single Bit: 1 byte (unavoidable in Swift)
// - Array<Bit>.Packed: 1 bit per element
// - Set<Bit>.Packed: 1 bit per element

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
/// print(a.flipped)       // Bit.zero
/// print(a.xor(b))        // Bit.one
/// print(Bit(true))       // Bit.one
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
@frozen
public enum Bit: UInt8, Sendable, Hashable, Equatable {
    /// Binary zero (false, off, low).
    case zero = 0

    /// Binary one (true, on, high).
    case one = 1
}

// MARK: - Inverse

extension Bit {
    /// Additive inverse (self, since a + a = 0 in Z₂).
    @inlinable
    public var inverse: Bit { self }
}

// MARK: - Initializers

extension Bit {
    /// Creates a bit from an arbitrary UInt8.
    ///
    /// Returns `nil` if the value is not 0 or 1.
    @inlinable
    public init?(_ value: UInt8) {
        self.init(rawValue: value)
    }

    /// Normalizing init - any nonzero becomes `.one`.
    ///
    /// Use for bulk extraction from packed words where the value
    /// is known to be a single masked bit (0 or nonzero).
    @inlinable
    public init(normalizing value: UInt8) {
        self = value == 0 ? .zero : .one
    }
}

// MARK: - Bitwise Operators

extension Bit {
    /// XOR (addition in Z₂).
    @inlinable
    public static func ^ (lhs: Bit, rhs: Bit) -> Bit {
        Bit(rawValue: lhs.rawValue ^ rhs.rawValue)!
    }

    /// XOR with integer (for `bit ^ 1` idiom).
    @inlinable
    public static func ^ (lhs: Bit, rhs: UInt8) -> Bit {
        Bit(normalizing: lhs.rawValue ^ (rhs & 1))
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

// MARK: - Flip / Toggle

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

// MARK: - Z₂ Field Operations

extension Bit {
    /// Z₂ field addition (XOR): 0+0=0, 0+1=1, 1+0=1, 1+1=0
    @inlinable
    public static func adding(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs ^ rhs
    }

    /// Z₂ field addition (XOR): 0+0=0, 0+1=1, 1+0=1, 1+1=0
    @inlinable
    public func adding(_ other: Bit) -> Bit {
        Bit.adding(self, other)
    }

    /// Z₂ field multiplication (AND): 0×0=0, 0×1=0, 1×0=0, 1×1=1
    @inlinable
    public static func multiplying(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs & rhs
    }

    /// Z₂ field multiplication (AND): 0×0=0, 0×1=0, 1×0=0, 1×1=1
    @inlinable
    public func multiplying(_ other: Bit) -> Bit {
        Bit.multiplying(self, other)
    }
}

// MARK: - Algebraic Identities

extension Bit {
    /// Algebraic identity elements for Z₂ field operations.
    public enum identity {
        /// Additive identity: 0 + x = x.
        @inlinable
        public static var additive: Bit { .zero }

        /// Multiplicative identity: 1 × x = x.
        @inlinable
        public static var multiplicative: Bit { .one }
    }
}

#if !hasFeature(Embedded)
extension Bit: Codable {}
#endif
