// Bit.Pattern.Ones Tests.swift

import Bit_Primitives_Test_Support
import Testing

@testable import Bit_Primitives

// 0b1010_1100 — set bits at positions 2, 3, 5, 7.
@Suite
struct `Bit Pattern Ones Tests` {
    let sample: UInt8 = 0b1010_1100

    @Test
    func `first and last set bit`() {
        #expect(Bit.Pattern<UInt8>.Ones(sample).first == 2)
        #expect(Bit.Pattern<UInt8>.Ones(sample).last == 7)
        #expect(Bit.Pattern<UInt8>.Ones(0).first == nil)
        #expect(Bit.Pattern<UInt8>.Ones(0).last == nil)
    }

    @Test
    func `rank counts set bits below a position`() {
        let ones = Bit.Pattern<UInt8>.Ones(sample)
        #expect(ones.rank(below: 0) == 0)
        #expect(ones.rank(below: 4) == 2)
        #expect(ones.rank(below: 8) == 4)
        #expect(ones.rank(below: 100) == 4)  // clamped to bitWidth
    }

    @Test
    func `select finds the nth set bit`() {
        let ones = Bit.Pattern<UInt8>.Ones(sample)
        #expect(ones.select(0) == 2)
        #expect(ones.select(1) == 3)
        #expect(ones.select(2) == 5)
        #expect(ones.select(3) == 7)
        #expect(ones.select(4) == nil)
        #expect(ones.select(-1) == nil)
    }

    @Test
    func `forEach visits set bits LSB-first`() {
        var visited: [Int] = []
        Bit.Pattern<UInt8>.Ones(sample).forEach { visited.append($0) }
        #expect(visited == [2, 3, 5, 7])
    }

    @Test
    func `all-set and all-clear words`() {
        #expect(Bit.Pattern<UInt8>.Ones(.max).first == 0)
        #expect(Bit.Pattern<UInt8>.Ones(.max).last == 7)
        #expect(Bit.Pattern<UInt8>.Ones(.max).rank(below: 8) == 8)
        #expect(Bit.Pattern<UInt8>.Ones(0).select(0) == nil)
    }
}
