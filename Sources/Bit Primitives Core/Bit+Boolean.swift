// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - NAND

extension Bit {
    /// NAND: NOT(a AND b). Returns `.zero` only when both bits are `.one`.
    ///
    /// One of two functionally complete single-operator bases (Sheffer stroke).
    /// Truth table: (0,0)→1, (0,1)→1, (1,0)→1, (1,1)→0
    @inlinable
    public static func nand(_ lhs: Bit, _ rhs: Bit) -> Bit {
        ~(lhs & rhs)
    }

    /// NAND: NOT(a AND b). Returns `.zero` only when both bits are `.one`.
    @inlinable
    public func nand(_ other: Bit) -> Bit {
        Bit.nand(self, other)
    }
}

// MARK: - NOR

extension Bit {
    /// NOR: NOT(a OR b). Returns `.one` only when both bits are `.zero`.
    ///
    /// One of two functionally complete single-operator bases (Peirce arrow).
    /// Truth table: (0,0)→1, (0,1)→0, (1,0)→0, (1,1)→0
    @inlinable
    public static func nor(_ lhs: Bit, _ rhs: Bit) -> Bit {
        ~(lhs | rhs)
    }

    /// NOR: NOT(a OR b). Returns `.one` only when both bits are `.zero`.
    @inlinable
    public func nor(_ other: Bit) -> Bit {
        Bit.nor(self, other)
    }
}

// MARK: - XNOR

extension Bit {
    /// XNOR: NOT(a XOR b). Returns `.one` when both bits are equal.
    ///
    /// Also called equivalence or biconditional. Hardware support:
    /// ARM EON, RISC-V XNOR.
    /// Truth table: (0,0)→1, (0,1)→0, (1,0)→0, (1,1)→1
    @inlinable
    public static func xnor(_ lhs: Bit, _ rhs: Bit) -> Bit {
        ~(lhs ^ rhs)
    }

    /// XNOR: NOT(a XOR b). Returns `.one` when both bits are equal.
    @inlinable
    public func xnor(_ other: Bit) -> Bit {
        Bit.xnor(self, other)
    }
}

// MARK: - AND-NOT

extension Bit {
    /// AND-NOT: a AND (NOT b). Clears `self` where `other` is set.
    ///
    /// Also called material non-implication or abjunction. Direct hardware
    /// support on all three major ISAs: x86 ANDN (BMI1), ARM BIC, RISC-V ANDN.
    /// Truth table: (0,0)→0, (0,1)→0, (1,0)→1, (1,1)→0
    @inlinable
    public static func andNot(_ lhs: Bit, _ rhs: Bit) -> Bit {
        lhs & ~rhs
    }

    /// AND-NOT: a AND (NOT b). Clears `self` where `other` is set.
    @inlinable
    public func andNot(_ other: Bit) -> Bit {
        Bit.andNot(self, other)
    }
}
