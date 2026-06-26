//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

import Bit_Primitive

// MARK: - CustomStringConvertible

extension Bit: CustomStringConvertible {
    /// A textual representation of the bit, `"0"` or `"1"`.
    public var description: String {
        switch self {
        case .zero: "0"
        case .one: "1"
        }
    }
}
