// Bit.swift

/// Binary digit: zero or one.
///
/// The fundamental unit of information. Forms the two-element Boolean algebra
/// ⟨{0, 1}, ∧, ∨, ¬, 0, 1⟩ and the Z₂ field ⟨{0, 1}, +, ×⟩ where
/// addition is XOR and multiplication is AND.
///
/// ```swift
/// let a: Bit = .one
/// let b: Bit = .zero
/// a ^ b          // .one   (Z₂ addition)
/// a & b          // .zero  (Z₂ multiplication)
/// ~a             // .zero  (complement)
/// a.adding(b)    // .one   (field addition)
/// ```
@frozen
public enum Bit: UInt8, Sendable, Hashable, Equatable {
    /// Binary zero (false, off, low).
    case zero = 0

    /// Binary one (true, on, high).
    case one = 1

    /// Creates a bit from an arbitrary UInt8.
    ///
    /// Returns `nil` if the value is not 0 or 1.
    @inlinable
    public init?(_ value: UInt8) {
        self.init(rawValue: value)
    }
}
