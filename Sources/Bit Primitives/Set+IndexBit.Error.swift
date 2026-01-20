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

// MARK: - Hoisted Error Types

/// Hoisted implementation of ``Set<Bit.Index>.Packed.Bounded.Error``.
///
/// - Note: Use ``Set<Bit.Index>.Packed.Bounded.Error`` in your code, not this type directly.
public enum __SetIndexBitPackedBoundedError: Swift.Error, Sendable, Equatable {
    case overflow(member: Int, capacity: Int)
}

/// Hoisted implementation of ``Set<Bit.Index>.Packed.Inline.Error``.
///
/// - Note: Use ``Set<Bit.Index>.Packed.Inline.Error`` in your code, not this type directly.
public enum __SetIndexBitPackedInlineError: Swift.Error, Sendable, Equatable {
    case overflow(member: Int, capacity: Int)
}

// MARK: - Canonical API: Error Typealiases

extension __SetIndexBitPacked.Bounded {
    /// Errors that can occur during bounded packed bit index set operations.
    public typealias Error = __SetIndexBitPackedBoundedError
}

extension __SetIndexBitPacked.Inline {
    /// Errors that can occur during inline packed bit index set operations.
    public typealias Error = __SetIndexBitPackedInlineError
}
