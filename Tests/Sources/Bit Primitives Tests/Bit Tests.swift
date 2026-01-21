// Bit Tests.swift

import Foundation
import Testing

@testable import Bit_Primitives

// MARK: - Bit - Memory Layout

@Suite
struct `Bit - Memory Layout` {
    @Test
    func `memory layout is exactly 1 byte`() {
        #expect(MemoryLayout<Bit>.size == 1)
        #expect(MemoryLayout<Bit>.stride == 1)
    }
}

// MARK: - Bit - Basic Tests

@Suite
struct `Bit - Basic` {
    @Test
    func `zero and one constants`() {
        #expect(Bit.zero == 0)
        #expect(Bit.one == 1)
    }

    @Test
    func `flipped operation`() {
        #expect(Bit.zero.flipped == .one)
        #expect(Bit.one.flipped == .zero)
    }

    @Test
    func `toggled is alias for flipped`() {
        #expect(Bit.zero.toggled == Bit.zero.flipped)
        #expect(Bit.one.toggled == Bit.one.flipped)
    }

    @Test
    func `prefix NOT operator`() {
        #expect(!Bit.zero == .one)
        #expect(!Bit.one == .zero)
    }
}

// MARK: - Bit - Boolean Operations

@Suite
struct `Bit - Boolean Operations` {
    @Test
    func `AND operation`() {
        #expect(Bit.and(.zero, .zero) == .zero)
        #expect(Bit.and(.zero, .one) == .zero)
        #expect(Bit.and(.one, .zero) == .zero)
        #expect(Bit.and(.one, .one) == .one)
    }

    @Test
    func `OR operation`() {
        #expect(Bit.or(.zero, .zero) == .zero)
        #expect(Bit.or(.zero, .one) == .one)
        #expect(Bit.or(.one, .zero) == .one)
        #expect(Bit.or(.one, .one) == .one)
    }

    @Test
    func `XOR operation`() {
        #expect(Bit.xor(.zero, .zero) == .zero)
        #expect(Bit.xor(.zero, .one) == .one)
        #expect(Bit.xor(.one, .zero) == .one)
        #expect(Bit.xor(.one, .one) == .zero)
    }
}

// MARK: - Bit - Boolean Conversion

@Suite
struct `Bit - Boolean Conversion` {
    @Test
    func `init from Bool`() {
        #expect(Bit(true) == .one)
        #expect(Bit(false) == .zero)
    }

    @Test
    func `boolValue property`() {
        #expect(Bit.one.boolValue == true)
        #expect(Bit.zero.boolValue == false)
    }
}

// MARK: - Bit - CaseIterable

@Suite
struct `Bit - CaseIterable` {
    @Test
    func `allCases contains zero and one`() {
        #expect(Bit.allCases.count == 2)
        #expect(Bit.allCases.contains(.zero))
        #expect(Bit.allCases.contains(.one))
    }
}

// MARK: - Bit - Initializers

@Suite
struct `Bit - Initializers` {
    @Test
    func `normalizing init coerces nonzero to one`() {
        #expect(Bit(normalizing: 0) == .zero)
        #expect(Bit(normalizing: 1) == .one)
        #expect(Bit(normalizing: 2) == .one)
        #expect(Bit(normalizing: 255) == .one)
    }

    @Test
    func `failable init from UInt8`() {
        #expect(Bit(UInt8(0)) == .zero)
        #expect(Bit(UInt8(1)) == .one)
        #expect(Bit(UInt8(2)) == nil)
        #expect(Bit(UInt8(255)) == nil)
    }
}

// MARK: - Bit - Codable

@Suite
struct `Bit - Codable` {
    @Test
    func `Codable encodes as 0 and 1`() throws {
        let encoder = JSONEncoder()
        let zero = try encoder.encode(Bit.zero)
        let one = try encoder.encode(Bit.one)
        #expect(String(data: zero, encoding: .utf8) == "0")
        #expect(String(data: one, encoding: .utf8) == "1")
    }

    @Test
    func `Codable decodes from 0 and 1`() throws {
        let decoder = JSONDecoder()
        let zero = try decoder.decode(Bit.self, from: Data("0".utf8))
        let one = try decoder.decode(Bit.self, from: Data("1".utf8))
        #expect(zero == .zero)
        #expect(one == .one)
    }
}

// MARK: - Bit - Z2 Field Operations

@Suite
struct `Bit - Z2 Field` {
    @Test
    func `identity values`() {
        #expect(Bit.identity.additive == .zero)
        #expect(Bit.identity.multiplicative == .one)
    }

    @Test
    func `inverse is self`() {
        #expect(Bit.zero.inverse == .zero)
        #expect(Bit.one.inverse == .one)
    }

    @Test
    func `Z2 field addition is XOR`() {
        #expect(Bit.zero.adding(.zero) == .zero)
        #expect(Bit.zero.adding(.one) == .one)
        #expect(Bit.one.adding(.zero) == .one)
        #expect(Bit.one.adding(.one) == .zero) // 1+1=0 in Z₂
    }

    @Test
    func `Z2 field multiplication is AND`() {
        #expect(Bit.zero.multiplying(.zero) == .zero)
        #expect(Bit.zero.multiplying(.one) == .zero)
        #expect(Bit.one.multiplying(.zero) == .zero)
        #expect(Bit.one.multiplying(.one) == .one)
    }

    @Test
    func `static adding method`() {
        #expect(Bit.adding(.zero, .zero) == .zero)
        #expect(Bit.adding(.one, .one) == .zero)
    }

    @Test
    func `static multiplying method`() {
        #expect(Bit.multiplying(.zero, .one) == .zero)
        #expect(Bit.multiplying(.one, .one) == .one)
    }
}

// MARK: - Bit - Finite.Enumerable

@Suite
struct `Bit - Enumerable` {
    @Test
    func `count is 2`() {
        #expect(Bit.count == 2)
    }

    @Test
    func `ordinal values`() {
        #expect(Bit.zero.ordinal == 0)
        #expect(Bit.one.ordinal == 1)
    }

    @Test
    func `init from ordinal unchecked`() {
        #expect(Bit(__unchecked: (), ordinal: 0) == .zero)
        #expect(Bit(__unchecked: (), ordinal: 1) == .one)
    }
}

// MARK: - Bit.Order Tests

@Suite
struct `Bit_Order - Basic` {
    @Test
    func `msb and lsb cases exist`() {
        let msb: Bit.Order = .msb
        let lsb: Bit.Order = .lsb
        #expect(msb != lsb)
    }

    @Test
    func `opposite operation`() {
        #expect(Bit.Order.msb.opposite == .lsb)
        #expect(Bit.Order.lsb.opposite == .msb)
    }

    @Test
    func `prefix NOT operator`() {
        #expect(!Bit.Order.msb == .lsb)
        #expect(!Bit.Order.lsb == .msb)
    }

    @Test
    func `aliases`() {
        #expect(Bit.Order.`most significant bit first` == .msb)
        #expect(Bit.Order.`least significant bit first` == .lsb)
    }
}

// MARK: - Bit.Order - Enumerable

@Suite
struct `Bit_Order - Enumerable` {
    @Test
    func `count is 2`() {
        #expect(Bit.Order.count == 2)
    }

    @Test
    func `ordinal values`() {
        #expect(Bit.Order.msb.ordinal == 0)
        #expect(Bit.Order.lsb.ordinal == 1)
    }

    @Test
    func `init from ordinal`() {
        #expect(Bit.Order(0) == .msb)
        #expect(Bit.Order(1) == .lsb)
    }

    @Test
    func `allCases iteration`() {
        let allCases = Array(Bit.Order.allCases)
        #expect(allCases.count == 2)
        #expect(allCases[0] == .msb)
        #expect(allCases[1] == .lsb)
    }
}
