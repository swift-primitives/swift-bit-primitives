//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

import Identity_Primitives

// MARK: - Tagged Value

extension Bit.Order {
    /// A value tagged with its bit order.
    ///
    /// Use this to explicitly track bit order alongside data.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bitstream: Bit.Order.Value<[UInt8]> = .init(.msb, data)
    /// ```
    public typealias Value<Payload> = Tagged<Bit.Order, Payload>
}
