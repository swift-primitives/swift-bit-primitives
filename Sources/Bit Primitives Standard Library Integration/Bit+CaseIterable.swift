//
//  File.swift
//  swift-bit-primitives
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2026.
//

import Bit_Primitive

// MARK: - CaseIterable

extension Bit: CaseIterable {
    /// All bit values: `[.zero, .one]`.
    public static let allCases: [Bit] = [.zero, .one]
}
