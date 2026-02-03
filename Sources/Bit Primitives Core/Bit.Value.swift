//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

// MARK: - Tagged Value

extension Bit {
    /// A value paired with a bit flag.
    public typealias Value<Payload> = Pair<Bit, Payload>
}
