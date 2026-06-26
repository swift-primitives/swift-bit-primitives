// Bit.Pattern.Zeros Tests.swift

import Bit_Primitives_Test_Support
import Testing

@testable import Bit_Primitives

// 0b1010_1100 — clear bits at positions 0, 1, 4, 6 (complement: 0b0101_0011).
@Suite
struct `Bit Pattern Zeros Tests` {
    let sample: UInt8 = 0b1010_1100

    @Test
    func `first and last clear bit`() {
        #expect(Bit.Pattern<UInt8>.Zeros(sample).first == 0)
        #expect(Bit.Pattern<UInt8>.Zeros(sample).last == 6)
        #expect(Bit.Pattern<UInt8>.Zeros(.max).first == nil)
        #expect(Bit.Pattern<UInt8>.Zeros(.max).last == nil)
    }

    @Test
    func `rank counts clear bits below a position`() {
        let zeros = Bit.Pattern<UInt8>.Zeros(sample)
        #expect(zeros.rank(below: 0) == 0)
        #expect(zeros.rank(below: 4) == 2)
        #expect(zeros.rank(below: 8) == 4)
        #expect(zeros.rank(below: 100) == 4)  // clamped to bitWidth
    }

    @Test
    func `select finds the nth clear bit`() {
        let zeros = Bit.Pattern<UInt8>.Zeros(sample)
        #expect(zeros.select(0) == 0)
        #expect(zeros.select(1) == 1)
        #expect(zeros.select(2) == 4)
        #expect(zeros.select(3) == 6)
        #expect(zeros.select(4) == nil)
        #expect(zeros.select(-1) == nil)
    }

    @Test
    func `forEach visits clear bits LSB-first`() {
        var visited: [Int] = []
        Bit.Pattern<UInt8>.Zeros(sample).forEach { visited.append($0) }
        #expect(visited == [0, 1, 4, 6])
    }

    @Test
    func `rank0 plus rank1 equals the bound (symbol completeness)`() {
        let ones = Bit.Pattern<UInt8>.Ones(sample)
        let zeros = Bit.Pattern<UInt8>.Zeros(sample)
        for bound in 0...8 {
            #expect(zeros.rank(below: bound) + ones.rank(below: bound) == bound)
        }
    }
}
