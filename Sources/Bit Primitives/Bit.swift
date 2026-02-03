//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

import Bit_Primitives_Core

extension Bit {
    /// Normalizing init - any nonzero becomes `.one`.
    ///
    /// Use for bulk extraction from packed words where the value
    /// is known to be a single masked bit (0 or nonzero).
    @inlinable
    public init(normalizing value: UInt8) {
        self = value == 0 ? .zero : .one
    }
}
