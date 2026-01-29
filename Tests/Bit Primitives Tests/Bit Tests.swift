// Bit Tests.swift

import Testing

@testable import Bit_Primitives
import Bit_Primitives_Test_Support

// MARK: - Test Suite Declaration

extension Bit {
    @Suite
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Bit.Test.Unit {
    @Test
    func `memory layout is exactly 1 byte`() {
        #expect(MemoryLayout<Bit>.size == 1)
        #expect(MemoryLayout<Bit>.stride == 1)
    }

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

    @Test
    func `bitwise NOT operator`() {
        #expect(~Bit.zero == .one)
        #expect(~Bit.one == .zero)
    }

    @Test
    func `AND operation - static method`() {
        #expect(Bit.and(.zero, .zero) == .zero)
        #expect(Bit.and(.zero, .one) == .zero)
        #expect(Bit.and(.one, .zero) == .zero)
        #expect(Bit.and(.one, .one) == .one)
    }

    @Test
    func `AND operation - instance method`() {
        #expect(Bit.zero.and(.zero) == .zero)
        #expect(Bit.zero.and(.one) == .zero)
        #expect(Bit.one.and(.zero) == .zero)
        #expect(Bit.one.and(.one) == .one)
    }

    @Test
    func `AND operation - operator`() {
        #expect((Bit.zero & .zero) == .zero)
        #expect((Bit.zero & .one) == .zero)
        #expect((Bit.one & .zero) == .zero)
        #expect((Bit.one & .one) == .one)
    }

    @Test
    func `OR operation - static method`() {
        #expect(Bit.or(.zero, .zero) == .zero)
        #expect(Bit.or(.zero, .one) == .one)
        #expect(Bit.or(.one, .zero) == .one)
        #expect(Bit.or(.one, .one) == .one)
    }

    @Test
    func `OR operation - instance method`() {
        #expect(Bit.zero.or(.zero) == .zero)
        #expect(Bit.zero.or(.one) == .one)
        #expect(Bit.one.or(.zero) == .one)
        #expect(Bit.one.or(.one) == .one)
    }

    @Test
    func `OR operation - operator`() {
        #expect((Bit.zero | .zero) == .zero)
        #expect((Bit.zero | .one) == .one)
        #expect((Bit.one | .zero) == .one)
        #expect((Bit.one | .one) == .one)
    }

    @Test
    func `XOR operation - static method`() {
        #expect(Bit.xor(.zero, .zero) == .zero)
        #expect(Bit.xor(.zero, .one) == .one)
        #expect(Bit.xor(.one, .zero) == .one)
        #expect(Bit.xor(.one, .one) == .zero)
    }

    @Test
    func `XOR operation - instance method`() {
        #expect(Bit.zero.xor(.zero) == .zero)
        #expect(Bit.zero.xor(.one) == .one)
        #expect(Bit.one.xor(.zero) == .one)
        #expect(Bit.one.xor(.one) == .zero)
    }

    @Test
    func `XOR operation - operator`() {
        #expect((Bit.zero ^ .zero) == .zero)
        #expect((Bit.zero ^ .one) == .one)
        #expect((Bit.one ^ .zero) == .one)
        #expect((Bit.one ^ .one) == .zero)
    }

    @Test
    func `XOR with UInt8 operator`() {
        #expect((Bit.zero ^ UInt8(0)) == .zero)
        #expect((Bit.zero ^ UInt8(1)) == .one)
        #expect((Bit.one ^ UInt8(0)) == .one)
        #expect((Bit.one ^ UInt8(1)) == .zero)
    }

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

    @Test
    func `ExpressibleByBooleanLiteral`() {
        let one: Bit = true
        let zero: Bit = false
        #expect(one == .one)
        #expect(zero == .zero)
    }

    @Test
    func `ExpressibleByIntegerLiteral`() {
        let one: Bit = 1
        let zero: Bit = 0
        #expect(one == .one)
        #expect(zero == .zero)
    }

    @Test
    func `allCases contains zero and one`() {
        #expect(Bit.allCases.count == 2)
        #expect(Bit.allCases.contains(.zero))
        #expect(Bit.allCases.contains(.one))
    }

    @Test
    func `normalizing init coerces nonzero to one`() {
        #expect(Bit(normalizing: 0) == .zero)
        #expect(Bit(normalizing: 1) == .one)
        #expect(Bit(normalizing: 2) == .one)
        #expect(Bit(normalizing: 255) == .one)
    }

    @Test
    func `failable init from UInt8 - valid values`() {
        #expect(Bit(UInt8(0)) == .zero)
        #expect(Bit(UInt8(1)) == .one)
    }

    @Test
    func `Z2 field identity values`() {
        #expect(Bit.identity.additive == .zero)
        #expect(Bit.identity.multiplicative == .one)
    }

    @Test
    func `Z2 field inverse is self`() {
        #expect(Bit.zero.inverse == .zero)
        #expect(Bit.one.inverse == .one)
    }

    @Test
    func `Z2 field addition is XOR`() {
        #expect(Bit.zero.adding(.zero) == .zero)
        #expect(Bit.zero.adding(.one) == .one)
        #expect(Bit.one.adding(.zero) == .one)
        #expect(Bit.one.adding(.one) == .zero)
    }

    @Test
    func `Z2 field addition - static method`() {
        #expect(Bit.adding(.zero, .zero) == .zero)
        #expect(Bit.adding(.one, .one) == .zero)
    }

    @Test
    func `Z2 field multiplication is AND`() {
        #expect(Bit.zero.multiplying(.zero) == .zero)
        #expect(Bit.zero.multiplying(.one) == .zero)
        #expect(Bit.one.multiplying(.zero) == .zero)
        #expect(Bit.one.multiplying(.one) == .one)
    }

    @Test
    func `Z2 field multiplication - static method`() {
        #expect(Bit.multiplying(.zero, .one) == .zero)
        #expect(Bit.multiplying(.one, .one) == .one)
    }

    @Test
    func `Finite.Enumerable count is 2`() {
        #expect(Bit.count == 2)
    }

    @Test
    func `Finite.Enumerable ordinal values`() {
        #expect(Bit.zero.ordinal == 0)
        #expect(Bit.one.ordinal == 1)
    }

    @Test
    func `Finite.Enumerable init from ordinal unchecked`() {
        #expect(Bit(__unchecked: (), ordinal: 0) == .zero)
        #expect(Bit(__unchecked: (), ordinal: 1) == .one)
    }

    @Test
    func `Comparable ordering`() {
        #expect(Bit.zero < Bit.one)
        #expect(!(Bit.one < Bit.zero))
        #expect(!(Bit.zero < Bit.zero))
    }

    @Test
    func `CustomStringConvertible description`() {
        #expect(Bit.zero.description == "0")
        #expect(Bit.one.description == "1")
    }

    @Test
    func `static flipped function`() {
        #expect(Bit.flipped(.zero) == .one)
        #expect(Bit.flipped(.one) == .zero)
    }

    @Test
    func `static toggled function`() {
        #expect(Bit.toggled(.zero) == .one)
        #expect(Bit.toggled(.one) == .zero)
    }
}

// MARK: - Edge Case Tests

extension Bit.Test.EdgeCase {
    @Test
    func `failable init returns nil for invalid values`() {
        #expect(Bit(UInt8(2)) == nil)
        #expect(Bit(UInt8(255)) == nil)
        #expect(Bit(UInt8(128)) == nil)
    }
}

// MARK: - Performance Tests

extension Bit.Test.Performance {
    @Test
    func `boolean operation throughput`() {
        // Warmup
        for _ in 0..<100 {
            var result: Bit = .zero
            for i: UInt8 in 0..<100 {
                result = result ^ Bit(normalizing: i & 1)
            }
            _ = result
        }

        // Measured iterations
        for _ in 0..<1000 {
            var result: Bit = .zero
            for i: UInt8 in 0..<100 {
                result = result ^ Bit(normalizing: i & 1)
            }
            _ = result
        }
    }
}
