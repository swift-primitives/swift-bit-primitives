// Algebra.Field+Bit.swift

import Algebra_Field_Primitives
import Bit_Boolean_Primitives

/// Z₂ field witness for Bit.
///
/// The two-element field GF(2), also known as ℤ₂:
/// - Addition is XOR: 0⊕0=0, 0⊕1=1, 1⊕0=1, 1⊕1=0
/// - Multiplication is AND: 0⊗0=0, 0⊗1=0, 1⊗0=0, 1⊗1=1
/// - Additive identity: .zero
/// - Multiplicative identity: .one
/// - Every element is its own additive inverse (a ⊕ a = 0)
/// - The only nonzero element (.one) is its own multiplicative inverse
extension Algebra.Field where Element == Bit {
    /// The Z₂ field over bits.
    @inlinable
    public static var z2: Self {
        .init(
            additive: .init(
                group: .init(
                    identity: .zero,
                    combining: Bit.adding,
                    inverting: { $0 }
                )
            ),
            multiplicative: .init(
                monoid: .init(
                    identity: .one,
                    combining: Bit.multiplying
                )
            ),
            // WORKAROUND: Explicit typed-throws annotation on non-throwing closure.
            // WHY: Swift 6.4-dev IRGen regression — CMO inlines past the
            //      non-throwing→typed-throws thunk and asserts hasErrorResult()
            //      on the un-thunked closure (Types.h:5369).
            // TRACKING: Needs swiftlang/swift issue filed; not yet in tracker.
            // WHEN TO REMOVE: When dev toolchain snapshot passes without it.
            reciprocal: { (element: Bit) throws(Error) -> Bit in element }
        )
    }
}
