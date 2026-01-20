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

public import Array_Primitives

// MARK: - Canonical API: Array<Bit>.Packed

extension Array_Primitives.Array where Element == Bit {
    /// Packed boolean array using word-sized storage.
    ///
    /// `Array<Bit>.Packed` stores boolean values as individual bits, providing 8x space
    /// efficiency over `[Bool]`. Operations are O(1) for single bit access and O(n/64)
    /// for bulk operations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var bits = try Array<Bit>.Packed(count: 100)
    /// try bits.set(42)
    /// bits[42]           // true
    /// bits.popcount      // 1
    /// try bits.toggle(42)
    /// bits[42]           // false
    /// ```
    ///
    /// ## Variants
    ///
    /// - ``Array<Bit>.Packed``: Dynamically-growing storage (this type)
    /// - ``Array<Bit>.Packed.Bounded``: Fixed-capacity, throws on overflow
    /// - ``Array<Bit>.Packed.Inline``: Zero-allocation inline storage with compile-time capacity
    public typealias Packed = __ArrayBitPacked
}

// MARK: - Hoisted Implementation: __ArrayBitPacked

/// Hoisted implementation of ``Array<Bit>.Packed``.
///
/// - Note: Use ``Array<Bit>.Packed`` in your code, not this type directly.
public struct __ArrayBitPacked: Sendable {
    @usableFromInline
    static var _bitsPerWord: Int { UInt.bitWidth }

    @usableFromInline
    var _storage: ContiguousArray<UInt>

    @usableFromInline
    var _count: Int

    @inlinable
    public init() {
        self._storage = []
        self._count = 0
    }

    @inlinable
    public init(count: Int) throws(__ArrayBitPackedError) {
        guard count >= 0 else {
            throw .invalidCount
        }
        let wordCount = (count + Self._bitsPerWord - 1) / Self._bitsPerWord
        self._storage = ContiguousArray(repeating: 0, count: wordCount)
        self._count = count
    }
}

// MARK: - Bounded Variant

extension __ArrayBitPacked {
    /// Hoisted implementation of ``Array<Bit>.Packed.Bounded``.
    ///
    /// - Note: Use ``Array<Bit>.Packed.Bounded`` in your code, not this type directly.
    public struct Bounded: Sendable {
        @usableFromInline
        static var _bitsPerWord: Int { UInt.bitWidth }

        @usableFromInline
        var _storage: ContiguousArray<UInt>

        @usableFromInline
        var _count: Int

        public let capacity: Int

        @inlinable
        public init(capacity: Int) throws(__ArrayBitPackedBoundedError) {
            guard capacity >= 0 else {
                throw .invalidCount
            }
            let wordCount = (capacity + Self._bitsPerWord - 1) / Self._bitsPerWord
            self._storage = ContiguousArray(repeating: 0, count: wordCount)
            self._count = 0
            self.capacity = capacity
        }

        @inlinable
        public init(count: Int, capacity: Int) throws(__ArrayBitPackedBoundedError) {
            guard count >= 0 && capacity >= 0 else {
                throw .invalidCount
            }
            guard count <= capacity else {
                throw .overflow
            }
            let wordCount = (capacity + Self._bitsPerWord - 1) / Self._bitsPerWord
            self._storage = ContiguousArray(repeating: 0, count: wordCount)
            self._count = count
            self.capacity = capacity
        }
    }
}

// MARK: - Inline Variant

extension __ArrayBitPacked {
    /// Hoisted implementation of ``Array<Bit>.Packed.Inline``.
    ///
    /// - Note: Use ``Array<Bit>.Packed.Inline`` in your code, not this type directly.
    public struct Inline<let wordCount: Int>: Sendable {
        @usableFromInline
        static var _bitsPerWord: Int { UInt.bitWidth }

        @inlinable
        public static var capacity: Int { wordCount * _bitsPerWord }

        @usableFromInline
        var _storage: InlineArray<wordCount, UInt>

        @usableFromInline
        var _count: Int

        @inlinable
        public init() {
            self._storage = InlineArray(repeating: 0)
            self._count = 0
        }

        @inlinable
        public init(count: Int) throws(__ArrayBitPackedInlineError) {
            guard count >= 0 && count <= Self.capacity else {
                throw .overflow
            }
            self._storage = InlineArray(repeating: 0)
            self._count = count
        }
    }
}

// MARK: - Properties

extension __ArrayBitPacked {
    @inlinable
    public var count: Int { _count }

    @inlinable
    public var isEmpty: Bool { _count == 0 }

    @inlinable
    public var popcount: Int {
        var total = 0
        for word in _storage {
            total += word.nonzeroBitCount
        }
        return total
    }

    @usableFromInline
    var _wordCount: Int { _storage.count }
}

extension __ArrayBitPacked.Bounded {
    @inlinable
    public var count: Int { _count }

    @inlinable
    public var isEmpty: Bool { _count == 0 }

    @inlinable
    public var isFull: Bool { _count >= capacity }

    @inlinable
    public var popcount: Int {
        var total = 0
        for word in _storage {
            total += word.nonzeroBitCount
        }
        return total
    }
}

extension __ArrayBitPacked.Inline {
    @inlinable
    public var count: Int { _count }

    @inlinable
    public var isEmpty: Bool { _count == 0 }

    @inlinable
    public var isFull: Bool { _count >= Self.capacity }

    @inlinable
    public var popcount: Int {
        var total = 0
        for i in 0..<wordCount {
            total += _storage[i].nonzeroBitCount
        }
        return total
    }
}

// MARK: - Subscript Access

extension __ArrayBitPacked {
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

    @inlinable
    public func get(_ index: Int) throws(__ArrayBitPackedError) -> Bool {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (_storage[wordIndex] & mask) != 0
    }
}

extension __ArrayBitPacked.Bounded {
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

    @inlinable
    public func get(_ index: Int) throws(__ArrayBitPackedBoundedError) -> Bool {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (_storage[wordIndex] & mask) != 0
    }
}

extension __ArrayBitPacked.Inline {
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

    @inlinable
    public func get(_ index: Int) throws(__ArrayBitPackedInlineError) -> Bool {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (_storage[wordIndex] & mask) != 0
    }
}

// MARK: - Bit Operations

extension __ArrayBitPacked {
    @inlinable
    public mutating func set(_ index: Int) throws(__ArrayBitPackedError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] |= mask
    }

    @inlinable
    public mutating func clear(_ index: Int) throws(__ArrayBitPackedError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] &= ~mask
    }

    @inlinable
    public mutating func toggle(_ index: Int) throws(__ArrayBitPackedError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] ^= mask
    }

    @inlinable
    public mutating func clearAll() {
        for i in 0..<_storage.count {
            _storage[i] = 0
        }
    }

    @inlinable
    public mutating func setAll() {
        for i in 0..<_storage.count {
            _storage[i] = ~0
        }
        let unusedBits = _storage.count * Self._bitsPerWord - _count
        if unusedBits > 0 && !_storage.isEmpty {
            let lastWord = _storage.count - 1
            let mask: UInt = ~0 >> unusedBits
            _storage[lastWord] = mask
        }
    }
}

extension __ArrayBitPacked.Bounded {
    @inlinable
    public mutating func set(_ index: Int) throws(__ArrayBitPackedBoundedError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] |= mask
    }

    @inlinable
    public mutating func clear(_ index: Int) throws(__ArrayBitPackedBoundedError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] &= ~mask
    }

    @inlinable
    public mutating func toggle(_ index: Int) throws(__ArrayBitPackedBoundedError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] ^= mask
    }

    @inlinable
    public mutating func clearAll() {
        for i in 0..<_storage.count {
            _storage[i] = 0
        }
    }

    @inlinable
    public mutating func setAll() {
        for i in 0..<_storage.count {
            _storage[i] = ~0
        }
        let unusedBits = _storage.count * Self._bitsPerWord - _count
        if unusedBits > 0 && !_storage.isEmpty {
            let lastWord = _storage.count - 1
            let mask: UInt = ~0 >> unusedBits
            _storage[lastWord] = mask
        }
    }
}

extension __ArrayBitPacked.Inline {
    @inlinable
    public mutating func set(_ index: Int) throws(__ArrayBitPackedInlineError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] |= mask
    }

    @inlinable
    public mutating func clear(_ index: Int) throws(__ArrayBitPackedInlineError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] &= ~mask
    }

    @inlinable
    public mutating func toggle(_ index: Int) throws(__ArrayBitPackedInlineError) {
        guard index >= 0 && index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let wordIndex = index / Self._bitsPerWord
        let bitIndex = index % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        _storage[wordIndex] ^= mask
    }

    @inlinable
    public mutating func clearAll() {
        for i in 0..<wordCount {
            _storage[i] = 0
        }
    }

    @inlinable
    public mutating func setAll() {
        for i in 0..<wordCount {
            _storage[i] = ~0
        }
        let unusedBits = wordCount * Self._bitsPerWord - _count
        if unusedBits > 0 && wordCount > 0 {
            let lastWord = wordCount - 1
            let mask: UInt = ~0 >> unusedBits
            _storage[lastWord] = mask
        }
    }
}

// MARK: - Resize

extension __ArrayBitPacked {
    @inlinable
    public mutating func resize(to newCount: Int, fill: Bool = false) throws(__ArrayBitPackedError) {
        guard newCount >= 0 else {
            throw .invalidCount
        }

        let oldCount = _count
        let oldWordCount = _storage.count
        let newWordCount = (newCount + Self._bitsPerWord - 1) / Self._bitsPerWord

        if newWordCount > oldWordCount {
            let fillValue: UInt = fill ? ~0 : 0
            _storage.reserveCapacity(newWordCount)
            for _ in oldWordCount..<newWordCount {
                _storage.append(fillValue)
            }
        } else if newWordCount < oldWordCount {
            _storage.removeLast(oldWordCount - newWordCount)
        }

        if fill && newCount > oldCount && oldWordCount > 0 {
            let oldBitInWord = oldCount % Self._bitsPerWord
            if oldBitInWord > 0 {
                let firstWordIndex = oldCount / Self._bitsPerWord
                if firstWordIndex < newWordCount {
                    let highMask: UInt = ~0 << oldBitInWord
                    _storage[firstWordIndex] |= highMask
                }
            }
        }

        _count = newCount

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

extension __ArrayBitPacked.Bounded {
    @inlinable
    public mutating func resize(to newCount: Int, fill: Bool = false) throws(__ArrayBitPackedBoundedError) {
        guard newCount >= 0 else {
            throw .invalidCount
        }
        guard newCount <= capacity else {
            throw .overflow
        }

        let oldCount = _count

        if fill && newCount > oldCount {
            let oldWordIndex = oldCount / Self._bitsPerWord
            let newWordIndex = (newCount - 1) / Self._bitsPerWord

            if oldCount % Self._bitsPerWord != 0 {
                let highMask: UInt = ~0 << (oldCount % Self._bitsPerWord)
                _storage[oldWordIndex] |= highMask
            }

            for i in (oldWordIndex + 1)...newWordIndex {
                _storage[i] = ~0
            }
        }

        _count = newCount

        let wordCount = (newCount + Self._bitsPerWord - 1) / Self._bitsPerWord
        if wordCount > 0 {
            let unusedBits = wordCount * Self._bitsPerWord - newCount
            if unusedBits > 0 {
                let lastWord = wordCount - 1
                let mask: UInt = ~0 >> unusedBits
                _storage[lastWord] &= mask
            }
        }
    }
}

extension __ArrayBitPacked.Inline {
    @inlinable
    public mutating func resize(to newCount: Int, fill: Bool = false) throws(__ArrayBitPackedInlineError) {
        guard newCount >= 0 && newCount <= Self.capacity else {
            throw .overflow
        }

        let oldCount = _count

        if fill && newCount > oldCount {
            let oldWordIndex = oldCount / Self._bitsPerWord
            let newWordIndex = (newCount - 1) / Self._bitsPerWord

            if oldCount % Self._bitsPerWord != 0 {
                let highMask: UInt = ~0 << (oldCount % Self._bitsPerWord)
                _storage[oldWordIndex] |= highMask
            }

            for i in (oldWordIndex + 1)...newWordIndex {
                _storage[i] = ~0
            }
        }

        _count = newCount

        let usedWordCount = (newCount + Self._bitsPerWord - 1) / Self._bitsPerWord
        if usedWordCount > 0 {
            let unusedBits = usedWordCount * Self._bitsPerWord - newCount
            if unusedBits > 0 {
                let lastWord = usedWordCount - 1
                let mask: UInt = ~0 >> unusedBits
                _storage[lastWord] &= mask
            }
        }
    }
}

// MARK: - Iteration

extension __ArrayBitPacked {
    @inlinable
    public func forEachSetBit(_ body: (Int) -> Void) {
        for (wordIndex, var word) in _storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self._bitsPerWord + bitIndex
                if globalIndex < _count {
                    body(globalIndex)
                }
                word &= word - 1
            }
        }
    }
}

extension __ArrayBitPacked.Bounded {
    @inlinable
    public func forEachSetBit(_ body: (Int) -> Void) {
        for (wordIndex, var word) in _storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self._bitsPerWord + bitIndex
                if globalIndex < _count {
                    body(globalIndex)
                }
                word &= word - 1
            }
        }
    }
}

extension __ArrayBitPacked.Inline {
    @inlinable
    public func forEachSetBit(_ body: (Int) -> Void) {
        for wordIndex in 0..<wordCount {
            var word = _storage[wordIndex]
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self._bitsPerWord + bitIndex
                if globalIndex < _count {
                    body(globalIndex)
                }
                word &= word - 1
            }
        }
    }
}

// MARK: - Equatable

extension __ArrayBitPacked: Equatable {}
extension __ArrayBitPacked.Bounded: Equatable {}

extension __ArrayBitPacked.Inline: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        for i in 0..<wordCount {
            if lhs._storage[i] != rhs._storage[i] { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension __ArrayBitPacked: Hashable {}
extension __ArrayBitPacked.Bounded: Hashable {}

extension __ArrayBitPacked.Inline: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_count)
        for i in 0..<wordCount {
            hasher.combine(_storage[i])
        }
    }
}
