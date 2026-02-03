//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

import Bit_Primitives_Core

// MARK: - CustomStringConvertible

extension Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .zero: "0"
        case .one: "1"
        }
    }
}
