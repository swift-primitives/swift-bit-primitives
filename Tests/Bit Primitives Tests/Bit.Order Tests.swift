// Bit.Order Tests.swift

import Bit_Primitives_Test_Support
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
    @Test
    func `msb and lsb cases exist`() {
        let msb: Bit.Order = .msb
        let lsb: Bit.Order = .lsb
        #expect(msb != lsb)
    }

    @Test
    func `opposite operation - instance property`() {
        #expect(Bit.Order.msb.opposite == .lsb)
        #expect(Bit.Order.lsb.opposite == .msb)
    }

    @Test
    func `opposite operation - static function`() {
        #expect(Bit.Order.opposite(.msb) == .lsb)
        #expect(Bit.Order.opposite(.lsb) == .msb)
    }

    @Test
    func `prefix NOT operator`() {
        #expect(!Bit.Order.msb == .lsb)
        #expect(!Bit.Order.lsb == .msb)
    }

    @Test
    func `most significant bit first alias`() {
        #expect(Bit.Order.`most significant bit first` == .msb)
    }

    @Test
    func `least significant bit first alias`() {
        #expect(Bit.Order.`least significant bit first` == .lsb)
    }

    @Test
    func `allCases iteration`() {
        let allCases = Array(Bit.Order.allCases)
        #expect(allCases.count == 2)
        #expect(allCases[0] == .msb)
        #expect(allCases[1] == .lsb)
    }

    @Test
    func `Hashable conformance`() {
        var set = Set<Bit.Order>()
        set.insert(.msb)
        set.insert(.lsb)
        #expect(set.count == 2)
        set.insert(.msb)
        #expect(set.count == 2)
    }

    @Test
    func `Equatable conformance`() {
        #expect(Bit.Order.msb == Bit.Order.msb)
        #expect(Bit.Order.lsb == Bit.Order.lsb)
        #expect(Bit.Order.msb != Bit.Order.lsb)
    }
}
