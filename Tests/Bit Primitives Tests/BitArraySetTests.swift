// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import Bit_Primitives

// MARK: - Bit.Array Tests

@Suite("Bit.Array")
struct BitArrayTests {

    @Test("Initialize empty")
    func initializeEmpty() {
        let bits = Bit.Array()
        #expect(bits.count == 0)
        #expect(bits.isEmpty == true)
        #expect(bits.popcount == 0)
    }

    @Test("Initialize with count")
    func initializeWithCount() {
        let bits = Bit.Array(count: 100)
        #expect(bits.count == 100)
        #expect(bits.popcount == 0)
    }

    @Test("Set and get bits")
    func setAndGetBits() {
        var bits = Bit.Array(count: 100)
        bits.set(0)
        bits.set(42)
        bits.set(99)

        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[42] == true)
        #expect(bits[99] == true)
        #expect(bits.popcount == 3)
    }

    @Test("Clear bits")
    func clearBits() {
        var bits = Bit.Array(count: 100)
        bits.set(42)
        #expect(bits[42] == true)

        bits.clear(42)
        #expect(bits[42] == false)
    }

    @Test("Toggle bits")
    func toggleBits() {
        var bits = Bit.Array(count: 100)
        #expect(bits[42] == false)

        bits.toggle(42)
        #expect(bits[42] == true)

        bits.toggle(42)
        #expect(bits[42] == false)
    }

    @Test("Subscript set")
    func subscriptSet() {
        var bits = Bit.Array(count: 100)
        bits[50] = true
        #expect(bits[50] == true)

        bits[50] = false
        #expect(bits[50] == false)
    }

    @Test("Clear all")
    func clearAll() {
        var bits = Bit.Array(count: 100)
        bits.set(10)
        bits.set(20)
        bits.set(30)

        #expect(bits.popcount == 3)

        bits.clearAll()

        #expect(bits.popcount == 0)
        #expect(bits[10] == false)
        #expect(bits[20] == false)
        #expect(bits[30] == false)
    }

    @Test("Set all")
    func setAll() {
        var bits = Bit.Array(count: 64)
        bits.setAll()

        #expect(bits.popcount == 64)
        for i in 0..<64 {
            #expect(bits[i] == true)
        }
    }

    @Test("Set all with partial word")
    func setAllPartialWord() {
        var bits = Bit.Array(count: 70)
        bits.setAll()

        #expect(bits.popcount == 70)
        for i in 0..<70 {
            #expect(bits[i] == true)
        }
    }

    @Test("Resize grow")
    func resizeGrow() {
        var bits = Bit.Array(count: 10)
        bits.set(5)

        bits.resize(to: 100)

        #expect(bits.count == 100)
        #expect(bits[5] == true)
        #expect(bits[50] == false)
    }

    @Test("Resize with fill")
    func resizeWithFill() {
        var bits = Bit.Array(count: 10)

        bits.resize(to: 100, fill: true)

        #expect(bits.count == 100)
        // New bits should be set
        #expect(bits[50] == true)
        #expect(bits[99] == true)
    }

    @Test("ForEach set bit")
    func forEachSetBit() {
        var bits = Bit.Array(count: 100)
        bits.set(5)
        bits.set(42)
        bits.set(77)

        var found: [Int] = []
        bits.forEachSetBit { found.append($0) }

        #expect(found == [5, 42, 77])
    }

    @Test("Cross word boundary")
    func crossWordBoundary() {
        var bits = Bit.Array(count: 128)
        bits.set(63)  // Last bit of first word
        bits.set(64)  // First bit of second word

        #expect(bits[63] == true)
        #expect(bits[64] == true)
        #expect(bits[62] == false)
        #expect(bits[65] == false)
    }
}

// MARK: - Bit.Set Tests

@Suite("Bit.Set")
struct BitSetTests {

    @Test("Initialize empty")
    func initializeEmpty() {
        let set = Bit.Set()
        #expect(set.count == 0)
        #expect(set.isEmpty == true)
    }

    @Test("Initialize from sequence")
    func initializeFromSequence() {
        let set = Bit.Set([1, 5, 10, 15])
        #expect(set.count == 4)
        #expect(set.contains(1) == true)
        #expect(set.contains(5) == true)
        #expect(set.contains(10) == true)
        #expect(set.contains(15) == true)
        #expect(set.contains(7) == false)
    }

    @Test("Insert and contains")
    func insertAndContains() {
        var set = Bit.Set()
        #expect(set.insert(42) == true)  // Newly inserted
        #expect(set.insert(42) == false) // Already present
        #expect(set.contains(42) == true)
        #expect(set.contains(43) == false)
    }

    @Test("Remove")
    func remove() {
        var set = Bit.Set([1, 2, 3])
        #expect(set.remove(2) == true)
        #expect(set.contains(2) == false)
        #expect(set.remove(2) == false)  // Already removed
    }

    @Test("Remove all")
    func removeAll() {
        var set = Bit.Set([1, 2, 3, 4, 5])
        #expect(set.isEmpty == false)

        set.removeAll()

        #expect(set.isEmpty == true)
        #expect(set.count == 0)
    }

    @Test("Min and max")
    func minAndMax() {
        let set = Bit.Set([5, 10, 100])
        #expect(set.min == 5)
        #expect(set.max == 100)
    }

    @Test("Empty min and max")
    func emptyMinMax() {
        let set = Bit.Set()
        #expect(set.min == nil)
        #expect(set.max == nil)
    }

    @Test("Union")
    func union() {
        let a = Bit.Set([1, 2, 3])
        let b = Bit.Set([3, 4, 5])
        let result = a.union(b)

        #expect(result.count == 5)
        for i in 1...5 {
            #expect(result.contains(i) == true)
        }
    }

    @Test("Intersection")
    func intersection() {
        let a = Bit.Set([1, 2, 3, 4])
        let b = Bit.Set([3, 4, 5, 6])
        let result = a.intersection(b)

        #expect(result.count == 2)
        #expect(result.contains(3) == true)
        #expect(result.contains(4) == true)
        #expect(result.contains(1) == false)
        #expect(result.contains(5) == false)
    }

    @Test("Symmetric difference")
    func symmetricDifference() {
        let a = Bit.Set([1, 2, 3])
        let b = Bit.Set([2, 3, 4])
        let result = a.symmetricDifference(b)

        #expect(result.count == 2)
        #expect(result.contains(1) == true)
        #expect(result.contains(4) == true)
        #expect(result.contains(2) == false)
        #expect(result.contains(3) == false)
    }

    @Test("Subtracting")
    func subtracting() {
        let a = Bit.Set([1, 2, 3, 4])
        let b = Bit.Set([2, 4])
        let result = a.subtracting(b)

        #expect(result.count == 2)
        #expect(result.contains(1) == true)
        #expect(result.contains(3) == true)
        #expect(result.contains(2) == false)
        #expect(result.contains(4) == false)
    }

    @Test("Is subset")
    func isSubset() {
        let a = Bit.Set([2, 3])
        let b = Bit.Set([1, 2, 3, 4])

        #expect(a.isSubset(of: b) == true)
        #expect(b.isSubset(of: a) == false)
    }

    @Test("Is superset")
    func isSuperset() {
        let a = Bit.Set([1, 2, 3, 4])
        let b = Bit.Set([2, 3])

        #expect(a.isSuperset(of: b) == true)
        #expect(b.isSuperset(of: a) == false)
    }

    @Test("Is disjoint")
    func isDisjoint() {
        let a = Bit.Set([1, 2, 3])
        let b = Bit.Set([4, 5, 6])
        let c = Bit.Set([3, 4, 5])

        #expect(a.isDisjoint(with: b) == true)
        #expect(a.isDisjoint(with: c) == false)
    }

    @Test("Form union")
    func formUnion() {
        var a = Bit.Set([1, 2])
        let b = Bit.Set([2, 3])
        a.formUnion(b)

        #expect(a.count == 3)
        #expect(a.contains(1) == true)
        #expect(a.contains(2) == true)
        #expect(a.contains(3) == true)
    }

    @Test("Form intersection")
    func formIntersection() {
        var a = Bit.Set([1, 2, 3])
        let b = Bit.Set([2, 3, 4])
        a.formIntersection(b)

        #expect(a.count == 2)
        #expect(a.contains(2) == true)
        #expect(a.contains(3) == true)
        #expect(a.contains(1) == false)
    }

    @Test("Subtract")
    func subtract() {
        var a = Bit.Set([1, 2, 3, 4])
        let b = Bit.Set([2, 4])
        a.subtract(b)

        #expect(a.count == 2)
        #expect(a.contains(1) == true)
        #expect(a.contains(3) == true)
    }

    @Test("ForEach")
    func forEach() {
        let set = Bit.Set([3, 7, 15])
        var found: [Int] = []
        set.forEach { found.append($0) }

        #expect(found.sorted() == [3, 7, 15])
    }

    @Test("Equality")
    func equality() {
        let a = Bit.Set([1, 2, 3])
        let b = Bit.Set([1, 2, 3])
        let c = Bit.Set([1, 2, 4])

        #expect(a == b)
        #expect(a != c)
    }

    @Test("Large member")
    func largeMember() {
        var set = Bit.Set()
        set.insert(1000)
        set.insert(5000)

        #expect(set.contains(1000) == true)
        #expect(set.contains(5000) == true)
        #expect(set.contains(2000) == false)
    }
}
