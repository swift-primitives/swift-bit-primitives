// Bit Tests.swift

import Testing

@testable import Bit_Primitives

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
    @Test("memory layout is exactly 1 byte")
    func memoryLayout() {
        #expect(MemoryLayout<Bit>.size == 1)
        #expect(MemoryLayout<Bit>.stride == 1)
    }

    @Test("zero and one constants")
    func zeroAndOneConstants() {
        #expect(Bit.zero == 0)
        #expect(Bit.one == 1)
    }

    @Test("flipped operation")
    func flippedOperation() {
        #expect(Bit.zero.flipped == .one)
        #expect(Bit.one.flipped == .zero)
    }

    @Test("toggled is alias for flipped")
    func toggledAlias() {
        #expect(Bit.zero.toggled == Bit.zero.flipped)
        #expect(Bit.one.toggled == Bit.one.flipped)
    }

    @Test("prefix NOT operator")
    func prefixNotOperator() {
        #expect(!Bit.zero == .one)
        #expect(!Bit.one == .zero)
    }

    @Test("bitwise NOT operator")
    func bitwiseNotOperator() {
        #expect(~Bit.zero == .one)
        #expect(~Bit.one == .zero)
    }

    @Test("AND operation - static method")
    func andOperationStatic() {
        #expect(Bit.and(.zero, .zero) == .zero)
        #expect(Bit.and(.zero, .one) == .zero)
        #expect(Bit.and(.one, .zero) == .zero)
        #expect(Bit.and(.one, .one) == .one)
    }

    @Test("AND operation - instance method")
    func andOperationInstance() {
        #expect(Bit.zero.and(.zero) == .zero)
        #expect(Bit.zero.and(.one) == .zero)
        #expect(Bit.one.and(.zero) == .zero)
        #expect(Bit.one.and(.one) == .one)
    }

    @Test("AND operation - operator")
    func andOperationOperator() {
        #expect((Bit.zero & .zero) == .zero)
        #expect((Bit.zero & .one) == .zero)
        #expect((Bit.one & .zero) == .zero)
        #expect((Bit.one & .one) == .one)
    }

    @Test("OR operation - static method")
    func orOperationStatic() {
        #expect(Bit.or(.zero, .zero) == .zero)
        #expect(Bit.or(.zero, .one) == .one)
        #expect(Bit.or(.one, .zero) == .one)
        #expect(Bit.or(.one, .one) == .one)
    }

    @Test("OR operation - instance method")
    func orOperationInstance() {
        #expect(Bit.zero.or(.zero) == .zero)
        #expect(Bit.zero.or(.one) == .one)
        #expect(Bit.one.or(.zero) == .one)
        #expect(Bit.one.or(.one) == .one)
    }

    @Test("OR operation - operator")
    func orOperationOperator() {
        #expect((Bit.zero | .zero) == .zero)
        #expect((Bit.zero | .one) == .one)
        #expect((Bit.one | .zero) == .one)
        #expect((Bit.one | .one) == .one)
    }

    @Test("XOR operation - static method")
    func xorOperationStatic() {
        #expect(Bit.xor(.zero, .zero) == .zero)
        #expect(Bit.xor(.zero, .one) == .one)
        #expect(Bit.xor(.one, .zero) == .one)
        #expect(Bit.xor(.one, .one) == .zero)
    }

    @Test("XOR operation - instance method")
    func xorOperationInstance() {
        #expect(Bit.zero.xor(.zero) == .zero)
        #expect(Bit.zero.xor(.one) == .one)
        #expect(Bit.one.xor(.zero) == .one)
        #expect(Bit.one.xor(.one) == .zero)
    }

    @Test("XOR operation - operator")
    func xorOperationOperator() {
        #expect((Bit.zero ^ .zero) == .zero)
        #expect((Bit.zero ^ .one) == .one)
        #expect((Bit.one ^ .zero) == .one)
        #expect((Bit.one ^ .one) == .zero)
    }

    @Test("XOR with UInt8 operator")
    func xorWithUInt8() {
        #expect((Bit.zero ^ UInt8(0)) == .zero)
        #expect((Bit.zero ^ UInt8(1)) == .one)
        #expect((Bit.one ^ UInt8(0)) == .one)
        #expect((Bit.one ^ UInt8(1)) == .zero)
    }

    @Test("init from Bool")
    func initFromBool() {
        #expect(Bit(true) == .one)
        #expect(Bit(false) == .zero)
    }

    @Test("boolValue property")
    func boolValueProperty() {
        #expect(Bit.one.boolValue == true)
        #expect(Bit.zero.boolValue == false)
    }

    @Test("ExpressibleByBooleanLiteral")
    func expressibleByBooleanLiteral() {
        let one: Bit = true
        let zero: Bit = false
        #expect(one == .one)
        #expect(zero == .zero)
    }

    @Test("ExpressibleByIntegerLiteral")
    func expressibleByIntegerLiteral() {
        let one: Bit = 1
        let zero: Bit = 0
        #expect(one == .one)
        #expect(zero == .zero)
    }

    @Test("allCases contains zero and one")
    func allCases() {
        #expect(Bit.allCases.count == 2)
        #expect(Bit.allCases.contains(.zero))
        #expect(Bit.allCases.contains(.one))
    }

    @Test("normalizing init coerces nonzero to one")
    func normalizingInit() {
        #expect(Bit(normalizing: 0) == .zero)
        #expect(Bit(normalizing: 1) == .one)
        #expect(Bit(normalizing: 2) == .one)
        #expect(Bit(normalizing: 255) == .one)
    }

    @Test("failable init from UInt8 - valid values")
    func failableInitValid() {
        #expect(Bit(UInt8(0)) == .zero)
        #expect(Bit(UInt8(1)) == .one)
    }

    @Test("Z₂ field identity values")
    func z2FieldIdentity() {
        #expect(Bit.identity.additive == .zero)
        #expect(Bit.identity.multiplicative == .one)
    }

    @Test("Z₂ field inverse is self")
    func z2FieldInverse() {
        #expect(Bit.zero.inverse == .zero)
        #expect(Bit.one.inverse == .one)
    }

    @Test("Z₂ field addition is XOR")
    func z2FieldAddition() {
        #expect(Bit.zero.adding(.zero) == .zero)
        #expect(Bit.zero.adding(.one) == .one)
        #expect(Bit.one.adding(.zero) == .one)
        #expect(Bit.one.adding(.one) == .zero)
    }

    @Test("Z₂ field addition - static method")
    func z2FieldAdditionStatic() {
        #expect(Bit.adding(.zero, .zero) == .zero)
        #expect(Bit.adding(.one, .one) == .zero)
    }

    @Test("Z₂ field multiplication is AND")
    func z2FieldMultiplication() {
        #expect(Bit.zero.multiplying(.zero) == .zero)
        #expect(Bit.zero.multiplying(.one) == .zero)
        #expect(Bit.one.multiplying(.zero) == .zero)
        #expect(Bit.one.multiplying(.one) == .one)
    }

    @Test("Z₂ field multiplication - static method")
    func z2FieldMultiplicationStatic() {
        #expect(Bit.multiplying(.zero, .one) == .zero)
        #expect(Bit.multiplying(.one, .one) == .one)
    }

    @Test("Finite.Enumerable count is 2")
    func enumerableCount() {
        #expect(Bit.count == 2)
    }

    @Test("Finite.Enumerable ordinal values")
    func enumerableOrdinal() {
        #expect(Bit.zero.ordinal == 0)
        #expect(Bit.one.ordinal == 1)
    }

    @Test("Finite.Enumerable init from ordinal unchecked")
    func enumerableInitFromOrdinal() {
        #expect(Bit(__unchecked: (), ordinal: 0) == .zero)
        #expect(Bit(__unchecked: (), ordinal: 1) == .one)
    }

    @Test("Comparable ordering")
    func comparableOrdering() {
        #expect(Bit.zero < Bit.one)
        #expect(!(Bit.one < Bit.zero))
        #expect(!(Bit.zero < Bit.zero))
    }

    @Test("CustomStringConvertible description")
    func description() {
        #expect(Bit.zero.description == "0")
        #expect(Bit.one.description == "1")
    }

    @Test("static flipped function")
    func staticFlipped() {
        #expect(Bit.flipped(.zero) == .one)
        #expect(Bit.flipped(.one) == .zero)
    }

    @Test("static toggled function")
    func staticToggled() {
        #expect(Bit.toggled(.zero) == .one)
        #expect(Bit.toggled(.one) == .zero)
    }
}

// MARK: - Edge Case Tests

extension Bit.Test.EdgeCase {
    @Test("failable init returns nil for invalid values")
    func failableInitInvalid() {
        #expect(Bit(UInt8(2)) == nil)
        #expect(Bit(UInt8(255)) == nil)
        #expect(Bit(UInt8(128)) == nil)
    }
}

// MARK: - Performance Tests

extension Bit.Test.Performance {
    @Test("boolean operation throughput")
    func booleanOperationThroughput() {
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
