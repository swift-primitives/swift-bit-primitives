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

public import Array_Primitives

// MARK: - Hoisted Error Types

/// Hoisted implementation of ``Array<Bit>.Packed.Error``.
///
/// - Note: Use ``Array<Bit>.Packed.Error`` in your code, not this type directly.
public enum __ArrayBitPackedError: Swift.Error, Sendable, Equatable {
    case bounds(index: Int, count: Int)
    case invalidCount
}

/// Hoisted implementation of ``Array<Bit>.Packed.Bounded.Error``.
///
/// - Note: Use ``Array<Bit>.Packed.Bounded.Error`` in your code, not this type directly.
public enum __ArrayBitPackedBoundedError: Swift.Error, Sendable, Equatable {
    case bounds(index: Int, count: Int)
    case invalidCount
    case overflow
}

/// Hoisted implementation of ``Array<Bit>.Packed.Inline.Error``.
///
/// - Note: Use ``Array<Bit>.Packed.Inline.Error`` in your code, not this type directly.
public enum __ArrayBitPackedInlineError: Swift.Error, Sendable, Equatable {
    case bounds(index: Int, count: Int)
    case overflow
}

// MARK: - Canonical API: Error Typealiases

extension __ArrayBitPacked {
    /// Errors that can occur during packed bit array operations.
    public typealias Error = __ArrayBitPackedError
}

extension __ArrayBitPacked.Bounded {
    /// Errors that can occur during bounded packed bit array operations.
    public typealias Error = __ArrayBitPackedBoundedError
}

extension __ArrayBitPacked.Inline {
    /// Errors that can occur during inline packed bit array operations.
    public typealias Error = __ArrayBitPackedInlineError
}
