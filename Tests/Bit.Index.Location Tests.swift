// Bit.Index.Location Tests.swift

import Testing

@testable import Bit_Primitives

// MARK: - Test Suite Declaration

extension Bit.Index.Location<UInt> {
    @Suite
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Bit.Index.Location<UInt>.Test.Unit {
    @Test("init from word, bit, and mask components")
    func initFromComponents() {
        let word = Index<UInt64>(__unchecked: (), Ordinal(5))
        let bit = Index<Bit>.Offset(Affine.Discrete.Vector(3))
        let mask: UInt64 = 1 << 3

        let location = Bit.Index.Location<UInt64>(word: word, bit: bit, mask: mask)

        #expect(location.word == word)
        #expect(location.bit == bit)
        #expect(location.mask == mask)
    }

    @Test("init from word and bit computes mask")
    func initFromWordAndBit() {
        let word = Index<UInt64>(__unchecked: (), Ordinal(0))
        let bit = Index<Bit>.Offset(Affine.Discrete.Vector(7))

        let location = Bit.Index.Location<UInt64>(word: word, bit: bit)

        #expect(location.word == word)
        #expect(location.bit == bit)
        #expect(location.mask == UInt64(1) << 7)
    }

    @Test("mask computation for bit 0")
    func maskForBitZero() {
        let word = Index<UInt64>(__unchecked: (), Ordinal(0))
        let bit = Index<Bit>.Offset(Affine.Discrete.Vector(0))

        let location = Bit.Index.Location<UInt64>(word: word, bit: bit)

        #expect(location.mask == 1)
    }

    @Test("mask computation for various bit positions")
    func maskForVariousBits() {
        for bitPosition in 0..<64 {
            let word = Index<UInt64>(__unchecked: (), Ordinal(0))
            let bit = Index<Bit>.Offset(Affine.Discrete.Vector(bitPosition))

            let location = Bit.Index.Location<UInt64>(word: word, bit: bit)

            #expect(location.mask == UInt64(1) << bitPosition)
        }
    }

    @Test("init from typed bit index")
    func initFromBitIndex() {
        // Bit index 70 with 64 bits per word should be word 1, bit 6
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(70))
        let location = Bit.Index.Location<UInt64>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 1)
        #expect(location.bit.rawValue.rawValue == 6)
        #expect(location.mask == UInt64(1) << 6)
    }

    @Test("init from typed bit count")
    func initFromBitCount() {
        // Bit count 70 with 64 bits per word should be word 1, bit 6
        let count = Bit.Index.Count(Cardinal(70))
        let location = Bit.Index.Location<UInt64>(count: count, bitsPerWord: .bitWidth)

        #expect(location.word.position == 1)
        #expect(location.bit.rawValue.rawValue == 6)
        #expect(location.mask == UInt64(1) << 6)
    }

    @Test("location for bit index 0")
    func locationForBitIndexZero() {
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(0))
        let location = Bit.Index.Location<UInt64>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 0)
        #expect(location.bit.rawValue.rawValue == 0)
        #expect(location.mask == 1)
    }

    @Test("location for bit index 63 (last bit of first word)")
    func locationForBitIndex63() {
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(63))
        let location = Bit.Index.Location<UInt64>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 0)
        #expect(location.bit.rawValue.rawValue == 63)
        #expect(location.mask == UInt64(1) << 63)
    }

    @Test("location for bit index 64 (first bit of second word)")
    func locationForBitIndex64() {
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(64))
        let location = Bit.Index.Location<UInt64>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 1)
        #expect(location.bit.rawValue.rawValue == 0)
        #expect(location.mask == 1)
    }

    @Test("UInt8 word type - 8 bits per word")
    func uint8WordType() {
        // Bit index 10 with 8 bits per word should be word 1, bit 2
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(10))
        let location = Bit.Index.Location<UInt8>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 1)
        #expect(location.bit.rawValue.rawValue == 2)
        #expect(location.mask == UInt8(1) << 2)
    }

    @Test("UInt32 word type - 32 bits per word")
    func uint32WordType() {
        // Bit index 35 with 32 bits per word should be word 1, bit 3
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(35))
        let location = Bit.Index.Location<UInt32>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 1)
        #expect(location.bit.rawValue.rawValue == 3)
        #expect(location.mask == UInt32(1) << 3)
    }
}

// MARK: - Edge Case Tests

extension Bit.Index.Location<UInt>.Test.EdgeCase {
    @Test("boundary: bit position 0 in word 0")
    func boundaryBitZero() {
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(0))
        let location = Bit.Index.Location<UInt64>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 0)
        #expect(location.bit.rawValue.rawValue == 0)
        #expect(location.mask == 1)
    }

    @Test("boundary: maximum bit position in UInt8 word")
    func boundaryMaxBitUInt8() {
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(7))
        let location = Bit.Index.Location<UInt8>(index: bitIndex, bitsPerWord: .bitWidth)

        #expect(location.word.position == 0)
        #expect(location.bit.rawValue.rawValue == 7)
        #expect(location.mask == UInt8(1) << 7)
    }

    @Test("boundary: word transition at UInt8 boundary")
    func boundaryWordTransitionUInt8() {
        // Bit 7 should be in word 0, bit 8 should be in word 1
        let bit7 = Bit.Index(__unchecked: (), Ordinal(7))
        let bit8 = Bit.Index(__unchecked: (), Ordinal(8))

        let loc7 = Bit.Index.Location<UInt8>(index: bit7, bitsPerWord: .bitWidth)
        let loc8 = Bit.Index.Location<UInt8>(index: bit8, bitsPerWord: .bitWidth)

        #expect(loc7.word.position == 0)
        #expect(loc7.bit.rawValue.rawValue == 7)

        #expect(loc8.word.position == 1)
        #expect(loc8.bit.rawValue.rawValue == 0)
    }

    @Test("large bit index")
    func largeBitIndex() {
        let bitIndex = Bit.Index(__unchecked: (), Ordinal(1000))
        let location = Bit.Index.Location<UInt64>(index: bitIndex, bitsPerWord: .bitWidth)

        // 1000 / 64 = 15, 1000 % 64 = 40
        #expect(location.word.position == 15)
        #expect(location.bit.rawValue.rawValue == 40)
        #expect(location.mask == UInt64(1) << 40)
    }
}

// MARK: - Storage Tests

extension Bit.Index.Storage<UInt> {
    @Suite
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension Bit.Index.Storage<UInt>.Test.Unit {
    @Test("storage for 0 bits")
    func storageForZeroBits() {
        let count = Bit.Index.Count(Cardinal(0))
        let storage = Bit.Index.Storage<UInt64>(count: count, bitsPerWord: .bitWidth)

        #expect(storage.wordCount.count == 0)
        #expect(storage.unusedBits.count == 0)
    }

    @Test("storage for exactly 64 bits")
    func storageForExactly64Bits() {
        let count = Bit.Index.Count(Cardinal(64))
        let storage = Bit.Index.Storage<UInt64>(count: count, bitsPerWord: .bitWidth)

        #expect(storage.wordCount.count == 1)
        #expect(storage.unusedBits.count == 0)
    }

    @Test("storage for 65 bits")
    func storageFor65Bits() {
        let count = Bit.Index.Count(Cardinal(65))
        let storage = Bit.Index.Storage<UInt64>(count: count, bitsPerWord: .bitWidth)

        #expect(storage.wordCount.count == 2)
        #expect(storage.unusedBits.count == 63)
    }

    @Test("storage for 100 bits")
    func storageFor100Bits() {
        let count = Bit.Index.Count(Cardinal(100))
        let storage = Bit.Index.Storage<UInt64>(count: count, bitsPerWord: .bitWidth)

        // 100 bits needs 2 words (128 bits capacity), with 28 unused
        #expect(storage.wordCount.count == 2)
        #expect(storage.unusedBits.count == 28)
    }

    @Test("storage for UInt8 words")
    func storageForUInt8Words() {
        let count = Bit.Index.Count(Cardinal(10))
        let storage = Bit.Index.Storage<UInt8>(count: count, bitsPerWord: .bitWidth)

        // 10 bits needs 2 bytes (16 bits capacity), with 6 unused
        #expect(storage.wordCount.count == 2)
        #expect(storage.unusedBits.count == 6)
    }

    @Test("capacity-based init")
    func capacityBasedInit() {
        let capacity = Bit.Index.Count(Cardinal(100))
        let storage = Bit.Index.Storage<UInt64>(capacity: capacity, bitsPerWord: .bitWidth)

        #expect(storage.wordCount.count == 2)
        #expect(storage.unusedBits.count == 28)
    }
}

extension Bit.Index.Storage<UInt>.Test.EdgeCase {
    @Test("storage for 1 bit")
    func storageForOneBit() {
        let count = Bit.Index.Count(Cardinal(1))
        let storage = Bit.Index.Storage<UInt64>(count: count, bitsPerWord: .bitWidth)

        #expect(storage.wordCount.count == 1)
        #expect(storage.unusedBits.count == 63)
    }

    @Test("storage at exact word boundary")
    func storageAtExactWordBoundary() {
        let count = Bit.Index.Count(Cardinal(128))
        let storage = Bit.Index.Storage<UInt64>(count: count, bitsPerWord: .bitWidth)

        #expect(storage.wordCount.count == 2)
        #expect(storage.unusedBits.count == 0)
    }
}
