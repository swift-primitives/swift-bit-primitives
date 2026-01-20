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
import Array_Primitives
import Index_Primitives

// MARK: - Array<Bit>.Packed Tests

@Suite("Array<Bit>.Packed")
struct ArrayBitPackedTests {

    @Test("Initialize empty")
    func initializeEmpty() {
        let bits = Array<Bit>.Packed()
        #expect(bits.count == 0)
        #expect(bits.isEmpty == true)
        #expect(bits.popcount == 0)
    }

    @Test("Initialize with count")
    func initializeWithCount() throws {
        let bits = try Array<Bit>.Packed(count: 100)
        #expect(bits.count == 100)
        #expect(bits.popcount == 0)
    }

    @Test("Set and get bits")
    func setAndGetBits() throws {
        var bits = try Array<Bit>.Packed(count: 100)
        try bits.set(0)
        try bits.set(42)
        try bits.set(99)

        #expect(bits[0] == true)
        #expect(bits[1] == false)
        #expect(bits[42] == true)
        #expect(bits[99] == true)
        #expect(bits.popcount == 3)
    }

    @Test("Clear bits")
    func clearBits() throws {
        var bits = try Array<Bit>.Packed(count: 100)
        try bits.set(42)
        #expect(bits[42] == true)

        try bits.clear(42)
        #expect(bits[42] == false)
    }

    @Test("Toggle bits")
    func toggleBits() throws {
        var bits = try Array<Bit>.Packed(count: 100)
        #expect(bits[42] == false)

        try bits.toggle(42)
        #expect(bits[42] == true)

        try bits.toggle(42)
        #expect(bits[42] == false)
    }

    @Test("Subscript set")
    func subscriptSet() throws {
        var bits = try Array<Bit>.Packed(count: 100)
        bits[50] = true
        #expect(bits[50] == true)

        bits[50] = false
        #expect(bits[50] == false)
    }

    @Test("Clear all")
    func clearAll() throws {
        var bits = try Array<Bit>.Packed(count: 100)
        try bits.set(10)
        try bits.set(20)
        try bits.set(30)

        #expect(bits.popcount == 3)

        bits.clearAll()

        #expect(bits.popcount == 0)
        #expect(bits[10] == false)
        #expect(bits[20] == false)
        #expect(bits[30] == false)
    }

    @Test("Set all")
    func setAll() throws {
        var bits = try Array<Bit>.Packed(count: 64)
        bits.setAll()

        #expect(bits.popcount == 64)
        for i in 0..<64 {
            #expect(bits[i] == true)
        }
    }

    @Test("Set all with partial word")
    func setAllPartialWord() throws {
        var bits = try Array<Bit>.Packed(count: 70)
        bits.setAll()

        #expect(bits.popcount == 70)
        for i in 0..<70 {
            #expect(bits[i] == true)
        }
    }

    @Test("Resize grow")
    func resizeGrow() throws {
        var bits = try Array<Bit>.Packed(count: 10)
        try bits.set(5)

        try bits.resize(to: 100)

        #expect(bits.count == 100)
        #expect(bits[5] == true)
        #expect(bits[50] == false)
    }

    @Test("Resize with fill")
    func resizeWithFill() throws {
        var bits = try Array<Bit>.Packed(count: 10)

        try bits.resize(to: 100, fill: true)

        #expect(bits.count == 100)
        // New bits should be set
        #expect(bits[50] == true)
        #expect(bits[99] == true)
    }

    @Test("ForEach set bit")
    func forEachSetBit() throws {
        var bits = try Array<Bit>.Packed(count: 100)
        try bits.set(5)
        try bits.set(42)
        try bits.set(77)

        var found: [Int] = []
        bits.forEachSetBit { found.append($0) }

        #expect(found == [5, 42, 77])
    }

    @Test("Cross word boundary")
    func crossWordBoundary() throws {
        var bits = try Array<Bit>.Packed(count: 128)
        try bits.set(63)  // Last bit of first word
        try bits.set(64)  // First bit of second word

        #expect(bits[63] == true)
        #expect(bits[64] == true)
        #expect(bits[62] == false)
        #expect(bits[65] == false)
    }
}

// MARK: - Set<Bit.Index>.Packed Tests

@Suite("Set<Bit.Index>.Packed")
struct SetBitIndexPackedTests {

    @Test("Initialize empty")
    func initializeEmpty() {
        let set = Set<Bit.Index>.Packed()
        #expect(set.count == 0)
        #expect(set.isEmpty == true)
    }

    @Test("Insert and contains")
    func insertAndContains() {
        var set = Set<Bit.Index>.Packed()
        #expect(set.insert(Bit.Index(42)) == true)  // Newly inserted
        #expect(set.insert(Bit.Index(42)) == false) // Already present
        #expect(set.contains(Bit.Index(42)) == true)
        #expect(set.contains(Bit.Index(43)) == false)
    }

    @Test("Remove")
    func remove() {
        var set = Set<Bit.Index>.Packed()
        set.insert(Bit.Index(1))
        set.insert(Bit.Index(2))
        set.insert(Bit.Index(3))

        #expect(set.remove(Bit.Index(2)) == true)
        #expect(set.contains(Bit.Index(2)) == false)
        #expect(set.remove(Bit.Index(2)) == false)  // Already removed
    }

    @Test("Remove all")
    func removeAll() {
        var set = Set<Bit.Index>.Packed()
        set.insert(Bit.Index(1))
        set.insert(Bit.Index(2))
        set.insert(Bit.Index(3))
        set.insert(Bit.Index(4))
        set.insert(Bit.Index(5))
        #expect(set.isEmpty == false)

        set.removeAll()

        #expect(set.isEmpty == true)
        #expect(set.count == 0)
    }

    @Test("Min and max")
    func minAndMax() {
        var set = Set<Bit.Index>.Packed()
        set.insert(Bit.Index(5))
        set.insert(Bit.Index(10))
        set.insert(Bit.Index(100))

        #expect(set.min == Bit.Index(5))
        #expect(set.max == Bit.Index(100))
    }

    @Test("Empty min and max")
    func emptyMinMax() {
        let set = Set<Bit.Index>.Packed()
        #expect(set.min == nil)
        #expect(set.max == nil)
    }

    @Test("Union")
    func union() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(3))
        b.insert(Bit.Index(4))
        b.insert(Bit.Index(5))

        let result = a.union(b)

        #expect(result.count == 5)
        for i in 1...5 {
            #expect(result.contains(Bit.Index(i)) == true)
        }
    }

    @Test("Intersection")
    func intersection() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))
        a.insert(Bit.Index(4))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(3))
        b.insert(Bit.Index(4))
        b.insert(Bit.Index(5))
        b.insert(Bit.Index(6))

        let result = a.intersection(b)

        #expect(result.count == 2)
        #expect(result.contains(Bit.Index(3)) == true)
        #expect(result.contains(Bit.Index(4)) == true)
        #expect(result.contains(Bit.Index(1)) == false)
        #expect(result.contains(Bit.Index(5)) == false)
    }

    @Test("Symmetric difference")
    func symmetricDifference() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(3))
        b.insert(Bit.Index(4))

        let result = a.symmetricDifference(b)

        #expect(result.count == 2)
        #expect(result.contains(Bit.Index(1)) == true)
        #expect(result.contains(Bit.Index(4)) == true)
        #expect(result.contains(Bit.Index(2)) == false)
        #expect(result.contains(Bit.Index(3)) == false)
    }

    @Test("Subtracting")
    func subtracting() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))
        a.insert(Bit.Index(4))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(4))

        let result = a.subtracting(b)

        #expect(result.count == 2)
        #expect(result.contains(Bit.Index(1)) == true)
        #expect(result.contains(Bit.Index(3)) == true)
        #expect(result.contains(Bit.Index(2)) == false)
        #expect(result.contains(Bit.Index(4)) == false)
    }

    @Test("Is subset")
    func isSubset() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(1))
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(3))
        b.insert(Bit.Index(4))

        #expect(a.isSubset(of: b) == true)
        #expect(b.isSubset(of: a) == false)
    }

    @Test("Is superset")
    func isSuperset() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))
        a.insert(Bit.Index(4))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(3))

        #expect(a.isSuperset(of: b) == true)
        #expect(b.isSuperset(of: a) == false)
    }

    @Test("Is disjoint")
    func isDisjoint() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(4))
        b.insert(Bit.Index(5))
        b.insert(Bit.Index(6))

        var c = Set<Bit.Index>.Packed()
        c.insert(Bit.Index(3))
        c.insert(Bit.Index(4))
        c.insert(Bit.Index(5))

        #expect(a.isDisjoint(with: b) == true)
        #expect(a.isDisjoint(with: c) == false)
    }

    @Test("Form union")
    func formUnion() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(3))

        a.formUnion(b)

        #expect(a.count == 3)
        #expect(a.contains(Bit.Index(1)) == true)
        #expect(a.contains(Bit.Index(2)) == true)
        #expect(a.contains(Bit.Index(3)) == true)
    }

    @Test("Form intersection")
    func formIntersection() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(3))
        b.insert(Bit.Index(4))

        a.formIntersection(b)

        #expect(a.count == 2)
        #expect(a.contains(Bit.Index(2)) == true)
        #expect(a.contains(Bit.Index(3)) == true)
        #expect(a.contains(Bit.Index(1)) == false)
    }

    @Test("Subtract")
    func subtract() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))
        a.insert(Bit.Index(4))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(4))

        a.subtract(b)

        #expect(a.count == 2)
        #expect(a.contains(Bit.Index(1)) == true)
        #expect(a.contains(Bit.Index(3)) == true)
    }

    @Test("ForEach")
    func forEach() {
        var set = Set<Bit.Index>.Packed()
        set.insert(Bit.Index(3))
        set.insert(Bit.Index(7))
        set.insert(Bit.Index(15))

        var found: [Int] = []
        set.forEach { found.append($0.position) }

        #expect(found.sorted() == [3, 7, 15])
    }

    @Test("Equality")
    func equality() {
        var a = Set<Bit.Index>.Packed()
        a.insert(Bit.Index(1))
        a.insert(Bit.Index(2))
        a.insert(Bit.Index(3))

        var b = Set<Bit.Index>.Packed()
        b.insert(Bit.Index(1))
        b.insert(Bit.Index(2))
        b.insert(Bit.Index(3))

        var c = Set<Bit.Index>.Packed()
        c.insert(Bit.Index(1))
        c.insert(Bit.Index(2))
        c.insert(Bit.Index(4))

        #expect(a == b)
        #expect(a != c)
    }

    @Test("Large member")
    func largeMember() {
        var set = Set<Bit.Index>.Packed()
        set.insert(Bit.Index(1000))
        set.insert(Bit.Index(5000))

        #expect(set.contains(Bit.Index(1000)) == true)
        #expect(set.contains(Bit.Index(5000)) == true)
        #expect(set.contains(Bit.Index(2000)) == false)
    }

    @Test("Index type safety")
    func indexTypeSafety() {
        let bitIndex = Bit.Index(42)
        let byteIndex = Index<UInt8>(42)

        // Same position but different types
        #expect(bitIndex.position == byteIndex.position)
        // Cannot compare directly - different types (compile-time safety)
    }

    @Test("Bit.Index shorthand")
    func bitIndexShorthand() {
        let idx1 = Index<Bit>(100)
        let idx2 = Bit.Index(100)

        #expect(idx1 == idx2)
    }
}
