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

extension Bit {
    /// Convenience typealias for ``Array<Bit>.Packed``.
    ///
    /// The canonical name is `Array<Bit>.Packed`. This typealias provides
    /// a shorter alternative following the `Bit.Array` naming pattern.
    public typealias Array = Array_Primitives.Array<Bit>.Packed
}
