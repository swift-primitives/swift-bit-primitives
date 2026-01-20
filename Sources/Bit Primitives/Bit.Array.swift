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

/// Packed boolean array using word-sized storage.
///
/// `Bit.Array` stores boolean values as individual bits, providing 8x space efficiency
/// over `[Bool]`. Operations are O(1) for single bit access and O(n/64) for bulk operations.
///
/// ## Example
///
/// ```swift
/// var bits = Bit.Array(count: 100)
/// bits.set(42)
/// bits[42]           // true
/// bits.popcount      // 1
/// bits.toggle(42)
/// bits[42]           // false
/// ```
///
/// ## Storage
///
/// Bits are stored in `UInt` words. Bit index 0 is the LSB of the first word.
/// The array automatically grows as needed.
extension Bit {
    public struct Array: Sendable {
        /// Bits per storage word.
        @usableFromInline
        static var _bitsPerWord: Int { UInt.bitWidth }

        /// Storage for bit words.
        @usableFromInline
        var _storage: ContiguousArray<UInt>

        /// Number of bits in the array.
        @usableFromInline
        var _count: Int

        /// Creates an empty bit array.
        @inlinable
        public init() {
            self._storage = []
            self._count = 0
        }

        /// Creates a bit array with the specified number of bits, all cleared.
        @inlinable
        public init(count: Int) {
            precondition(count >= 0, "Count must be non-negative")
            let wordCount = (count + Self._bitsPerWord - 1) / Self._bitsPerWord
            self._storage = ContiguousArray(repeating: 0, count: wordCount)
            self._count = count
        }
    }
}

// MARK: - Properties

extension Bit.Array {
    /// The number of bits in the array.
    @inlinable
    public var count: Int { _count }

    /// Whether the array is empty.
    @inlinable
    public var isEmpty: Bool { _count == 0 }

    /// The number of set bits (population count).
    @inlinable
    public var popcount: Int {
        var total = 0
        for word in _storage {
            total += word.nonzeroBitCount
        }
        return total
    }

    /// Number of storage words.
    @usableFromInline
    var _wordCount: Int { _storage.count }
}

// MARK: - Subscript Access

extension Bit.Array {
    /// Accesses the bit at the given index.
    @inlinable
    public subscript(index: Int) -> Bool {
        get {
            precondition(index >= 0 && index < _count, "Index out of bounds")
            let wordIndex = index / Self._bitsPerWord
            let bitIndex = index % Self._bitsPerWord
            let mask: UInt = 1 << bitIndex
            return (_storage[wordIndex] & mask) != 0
        }
        set {
            precondition(index >= 0 && index < _count, "Index out of bounds")
            let wordIndex = index / Self._bitsPerWord
            let bitIndex = index % Self._bitsPerWord
            let mask: UInt = 1 << bitIndex
            if newValue {
                _storage[wordIndex] |= mask
            } else {
                _storage[wordIndex] &= ~mask
            }
        }
    }
}

// MARK: - Bit Operations

extension Bit.Array {
    /// Sets the bit at the given index.
    @inlinable
    public mutating func set(_ index: Int) {
        precondition(index >= 0 && index < _count, "Index out of bounds")
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] |= mask
    }

    /// Clears the bit at the given index.
    @inlinable
    public mutating func clear(_ index: Int) {
        precondition(index >= 0 && index < _count, "Index out of bounds")
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] &= ~mask
    }

    /// Toggles the bit at the given index.
    @inlinable
    public mutating func toggle(_ index: Int) {
        precondition(index >= 0 && index < _count, "Index out of bounds")
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] ^= mask
    }

    /// Clears all bits.
    @inlinable
    public mutating func clearAll() {
        for i in 0..<_storage.count {
            _storage[i] = 0
        }
    }

    /// Sets all bits.
    @inlinable
    public mutating func setAll() {
        for i in 0..<_storage.count {
            _storage[i] = ~0
        }
        // Mask off unused bits in last word
        let unusedBits = _storage.count * Self._bitsPerWord - _count
        if unusedBits > 0 && !_storage.isEmpty {
            let lastWord = _storage.count - 1
            let mask: UInt = ~0 >> unusedBits
            _storage[lastWord] = mask
        }
    }
}

// MARK: - Resize

extension Bit.Array {
    /// Resizes the bit array to the specified count.
    ///
    /// New bits are initialized to the specified value (default: false).
    @inlinable
    public mutating func resize(to newCount: Int, fill: Bool = false) {
        precondition(newCount >= 0, "Count must be non-negative")

        let oldCount = _count
        let oldWordCount = _storage.count
        let newWordCount = (newCount + Self._bitsPerWord - 1) / Self._bitsPerWord

        if newWordCount > oldWordCount {
            // Grow storage
            let fillValue: UInt = fill ? ~0 : 0
            _storage.reserveCapacity(newWordCount)
            for _ in oldWordCount..<newWordCount {
                _storage.append(fillValue)
            }
        } else if newWordCount < oldWordCount {
            // Shrink storage
            _storage.removeLast(oldWordCount - newWordCount)
        }

        // Fill new bits within existing first word if growing
        if fill && newCount > oldCount && oldWordCount > 0 {
            let oldBitInWord = oldCount % Self._bitsPerWord
            if oldBitInWord > 0 {
                // Set bits from oldBitInWord to end of word (or newCount if in same word)
                let firstWordIndex = oldCount / Self._bitsPerWord
                if firstWordIndex < newWordCount {
                    // Create mask for bits from oldBitInWord to 63
                    let highMask: UInt = ~0 << oldBitInWord
                    _storage[firstWordIndex] |= highMask
                }
            }
        }

        _count = newCount

        // Mask off unused bits in last word if needed
        if newWordCount > 0 {
            let unusedBits = newWordCount * Self._bitsPerWord - newCount
            if unusedBits > 0 {
                let lastWord = newWordCount - 1
                let mask: UInt = ~0 >> unusedBits
                _storage[lastWord] &= mask
            }
        }
    }
}

// MARK: - Iteration

extension Bit.Array {
    /// Calls the given closure for each set bit index.
    @inlinable
    public func forEachSetBit(_ body: (Int) -> Void) {
        for (wordIndex, var word) in _storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self._bitsPerWord + bitIndex
                if globalIndex < _count {
                    body(globalIndex)
                }
                word &= word - 1  // Clear lowest set bit
            }
        }
    }
}

// MARK: - Equatable

extension Bit.Array: Equatable {}

// MARK: - Hashable

extension Bit.Array: Hashable {}
