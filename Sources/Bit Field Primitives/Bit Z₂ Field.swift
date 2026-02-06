// Bit Z₂ Field.swift
// GF(2) field operations: addition (XOR) and multiplication (AND).

import Bit_Boolean_Primitives

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
