// Bit Tests.swift

import Testing

@testable import Bit_Primitives

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
        #expect(Bit.Order(ordinal: 0) == .msb)
        #expect(Bit.Order(ordinal: 1) == .lsb)
    }

    @Test
    func `allCases iteration`() {
        let allCases = Array(Bit.Order.allCases)
        #expect(allCases.count == 2)
        #expect(allCases[0] == .msb)
        #expect(allCases[1] == .lsb)
    }
}
