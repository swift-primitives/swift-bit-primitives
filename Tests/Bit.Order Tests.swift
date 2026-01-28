// Bit.Order Tests.swift

import Testing

@testable import Bit_Primitives

// MARK: - Test Suite Declaration

extension Bit.Order {
    @Suite
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Bit.Order.Test.Unit {
    @Test("msb and lsb cases exist")
    func msbAndLsbCases() {
        let msb: Bit.Order = .msb
        let lsb: Bit.Order = .lsb
        #expect(msb != lsb)
    }

    @Test("opposite operation - instance property")
    func oppositeProperty() {
        #expect(Bit.Order.msb.opposite == .lsb)
        #expect(Bit.Order.lsb.opposite == .msb)
    }

    @Test("opposite operation - static function")
    func oppositeStatic() {
        #expect(Bit.Order.opposite(.msb) == .lsb)
        #expect(Bit.Order.opposite(.lsb) == .msb)
    }

    @Test("prefix NOT operator")
    func prefixNotOperator() {
        #expect(!Bit.Order.msb == .lsb)
        #expect(!Bit.Order.lsb == .msb)
    }

    @Test("most significant bit first alias")
    func msbAlias() {
        #expect(Bit.Order.`most significant bit first` == .msb)
    }

    @Test("least significant bit first alias")
    func lsbAlias() {
        #expect(Bit.Order.`least significant bit first` == .lsb)
    }

    @Test("Finite.Enumerable count is 2")
    func enumerableCount() {
        #expect(Bit.Order.count == 2)
    }

    @Test("Finite.Enumerable ordinal values")
    func enumerableOrdinal() {
        #expect(Bit.Order.msb.ordinal == 0)
        #expect(Bit.Order.lsb.ordinal == 1)
    }

    @Test("Finite.Enumerable init from ordinal unchecked")
    func enumerableInitFromOrdinal() {
        #expect(Bit.Order(__unchecked: (), ordinal: 0) == .msb)
        #expect(Bit.Order(__unchecked: (), ordinal: 1) == .lsb)
    }

    @Test("allCases iteration")
    func allCases() {
        let allCases = Array(Bit.Order.allCases)
        #expect(allCases.count == 2)
        #expect(allCases[0] == .msb)
        #expect(allCases[1] == .lsb)
    }

    @Test("Hashable conformance")
    func hashable() {
        var set = Set<Bit.Order>()
        set.insert(.msb)
        set.insert(.lsb)
        #expect(set.count == 2)
        set.insert(.msb)
        #expect(set.count == 2)
    }

    @Test("Equatable conformance")
    func equatable() {
        #expect(Bit.Order.msb == Bit.Order.msb)
        #expect(Bit.Order.lsb == Bit.Order.lsb)
        #expect(Bit.Order.msb != Bit.Order.lsb)
    }
}
