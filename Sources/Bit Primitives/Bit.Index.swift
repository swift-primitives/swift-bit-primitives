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

public import Index_Primitives

extension Bit {
    /// A position in a bit collection.
    ///
    /// `Bit.Index` is a typealias for `Index<Bit>`, providing a convenient
    /// shorthand for typed bit positions.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let idx = Bit.Index(42)
    /// let idx2: Bit.Index = 100
    /// ```
    public typealias Index = Index_Primitives.Index<Bit>
}
