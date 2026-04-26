// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-bit-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-bit-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Carrier_Primitives
public import Cardinal_Primitives

// MARK: - Cardinal Shift Operators

/// Left shift a fixed-width integer by a cardinal amount.
@inlinable
public func << <RawValue: FixedWidthInteger>(
    lhs: RawValue,
    rhs: some Carrier<Cardinal>
) -> RawValue {
    let shift = Int(bitPattern: rhs.cardinal)
    precondition(shift >= 0 && shift < RawValue.bitWidth, "Shift amount out of range")
    return lhs << shift
}

/// Right shift a fixed-width integer by a cardinal amount.
@inlinable
public func >> <RawValue: FixedWidthInteger>(
    lhs: RawValue,
    rhs: some Carrier<Cardinal>
) -> RawValue {
    let shift = Int(bitPattern: rhs.cardinal)
    precondition(shift >= 0 && shift < RawValue.bitWidth, "Shift amount out of range")
    return lhs >> shift
}

/// Left shift assignment by a cardinal amount.
@inlinable
public func <<= <RawValue: FixedWidthInteger>(
    lhs: inout RawValue,
    rhs: some Carrier<Cardinal>
) {
    lhs = lhs << rhs
}

/// Right shift assignment by a cardinal amount.
@inlinable
public func >>= <RawValue: FixedWidthInteger>(
    lhs: inout RawValue,
    rhs: some Carrier<Cardinal>
) {
    lhs = lhs >> rhs
}
