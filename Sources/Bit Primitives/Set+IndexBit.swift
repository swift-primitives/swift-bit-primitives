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

public import Index_Primitives

// MARK: - Canonical API: Set<Bit.Index>.Packed

extension Swift.Set where Element == Bit.Index {
    /// Packed bit index set using word-sized storage.
    ///
    /// `Set<Bit.Index>.Packed` stores bit positions using individual bits, providing
    /// O(1) insert, remove, and contains operations with minimal space overhead.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var set = Set<Bit.Index>.Packed()
    /// try set.insert(Bit.Index(42))
    /// set.contains(Bit.Index(42))  // true
    /// set.remove(Bit.Index(42))
    /// set.contains(Bit.Index(42))  // false
    /// ```
    ///
    /// ## Variants
    ///
    /// - ``Set<Bit.Index>.Packed``: Dynamically-growing storage (this type)
    /// - ``Set<Bit.Index>.Packed.Bounded``: Fixed-capacity, throws on overflow
    /// - ``Set<Bit.Index>.Packed.Inline``: Zero-allocation inline storage with compile-time capacity
    public typealias Packed = __SetIndexBitPacked
}

// MARK: - Hoisted Implementation: __SetIndexBitPacked

/// Hoisted implementation of ``Set<Bit.Index>.Packed``.
///
/// - Note: Use ``Set<Bit.Index>.Packed`` in your code, not this type directly.
public struct __SetIndexBitPacked: Sendable {
    @usableFromInline
    static var _bitsPerWord: Int { UInt.bitWidth }

    @usableFromInline
    var _storage: ContiguousArray<UInt>

    @inlinable
    public init() {
        self._storage = []
    }

    @inlinable
    public init(capacity: Int) {
        let wordCount = (capacity + Self._bitsPerWord - 1) / Self._bitsPerWord
        self._storage = ContiguousArray(repeating: 0, count: wordCount)
    }
}

// MARK: - Bounded Variant

extension __SetIndexBitPacked {
    /// Hoisted implementation of ``Set<Bit.Index>.Packed.Bounded``.
    ///
    /// - Note: Use ``Set<Bit.Index>.Packed.Bounded`` in your code, not this type directly.
    public struct Bounded: Sendable {
        @usableFromInline
        static var _bitsPerWord: Int { UInt.bitWidth }

        @usableFromInline
        var _storage: ContiguousArray<UInt>

        public let capacity: Int

        @inlinable
        public init(capacity: Int) {
            precondition(capacity >= 0)
            let wordCount = (capacity + Self._bitsPerWord - 1) / Self._bitsPerWord
            self._storage = ContiguousArray(repeating: 0, count: wordCount)
            self.capacity = capacity
        }
    }
}

// MARK: - Inline Variant

extension __SetIndexBitPacked {
    /// Hoisted implementation of ``Set<Bit.Index>.Packed.Inline``.
    ///
    /// - Note: Use ``Set<Bit.Index>.Packed.Inline`` in your code, not this type directly.
    public struct Inline<let wordCount: Int>: Sendable {
        @usableFromInline
        static var _bitsPerWord: Int { UInt.bitWidth }

        @inlinable
        public static var capacity: Int { wordCount * _bitsPerWord }

        @usableFromInline
        var _storage: InlineArray<wordCount, UInt>

        @inlinable
        public init() {
            self._storage = InlineArray(repeating: 0)
        }
    }
}

// MARK: - Properties

extension __SetIndexBitPacked {
    @inlinable
    public var isEmpty: Bool {
        for word in _storage {
            if word != 0 { return false }
        }
        return true
    }

    @inlinable
    public var count: Int {
        var total = 0
        for word in _storage {
            total += word.nonzeroBitCount
        }
        return total
    }

    @inlinable
    public var capacity: Int {
        _storage.count * Self._bitsPerWord
    }

    @inlinable
    public var max: Bit.Index? {
        for i in stride(from: _storage.count - 1, through: 0, by: -1) {
            let word = _storage[i]
            if word != 0 {
                let bitIndex = UInt.bitWidth - 1 - word.leadingZeroBitCount
                return Bit.Index(i * Self._bitsPerWord + bitIndex)
            }
        }
        return nil
    }

    @inlinable
    public var min: Bit.Index? {
        for (i, word) in _storage.enumerated() {
            if word != 0 {
                return Bit.Index(i * Self._bitsPerWord + word.trailingZeroBitCount)
            }
        }
        return nil
    }
}

extension __SetIndexBitPacked.Bounded {
    @inlinable
    public var isEmpty: Bool {
        for word in _storage {
            if word != 0 { return false }
        }
        return true
    }

    @inlinable
    public var count: Int {
        var total = 0
        for word in _storage {
            total += word.nonzeroBitCount
        }
        return total
    }
}

extension __SetIndexBitPacked.Inline {
    @inlinable
    public var isEmpty: Bool {
        for i in 0..<wordCount {
            if _storage[i] != 0 { return false }
        }
        return true
    }

    @inlinable
    public var count: Int {
        var total = 0
        for i in 0..<wordCount {
            total += _storage[i].nonzeroBitCount
        }
        return total
    }
}

// MARK: - Contains

extension __SetIndexBitPacked {
    @inlinable
    public func contains(_ member: Bit.Index) -> Bool {
        let wordIndex = member.position / Self._bitsPerWord
        guard wordIndex < _storage.count else { return false }
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (_storage[wordIndex] & mask) != 0
    }
}

extension __SetIndexBitPacked.Bounded {
    @inlinable
    public func contains(_ member: Bit.Index) -> Bool {
        guard member.position < capacity else { return false }
        let wordIndex = member.position / Self._bitsPerWord
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (_storage[wordIndex] & mask) != 0
    }
}

extension __SetIndexBitPacked.Inline {
    @inlinable
    public func contains(_ member: Bit.Index) -> Bool {
        guard member.position < Self.capacity else { return false }
        let wordIndex = member.position / Self._bitsPerWord
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (_storage[wordIndex] & mask) != 0
    }
}

// MARK: - Insert

extension __SetIndexBitPacked {
    @inlinable
    @discardableResult
    public mutating func insert(_ member: Bit.Index) -> Bool {
        let wordIndex = member.position / Self._bitsPerWord
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex

        if wordIndex >= _storage.count {
            let needed = wordIndex + 1
            _storage.reserveCapacity(needed)
            while _storage.count < needed {
                _storage.append(0)
            }
        }

        let wasAbsent = (_storage[wordIndex] & mask) == 0
        _storage[wordIndex] |= mask
        return wasAbsent
    }
}

extension __SetIndexBitPacked.Bounded {
    @inlinable
    @discardableResult
    public mutating func insert(_ member: Bit.Index) throws(__SetIndexBitPackedBoundedError) -> Bool {
        guard member.position < capacity else {
            throw .overflow(member: member.position, capacity: capacity)
        }

        let wordIndex = member.position / Self._bitsPerWord
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex

        let wasAbsent = (_storage[wordIndex] & mask) == 0
        _storage[wordIndex] |= mask
        return wasAbsent
    }
}

extension __SetIndexBitPacked.Inline {
    @inlinable
    @discardableResult
    public mutating func insert(_ member: Bit.Index) throws(__SetIndexBitPackedInlineError) -> Bool {
        guard member.position < Self.capacity else {
            throw .overflow(member: member.position, capacity: Self.capacity)
        }

        let wordIndex = member.position / Self._bitsPerWord
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex

        let wasAbsent = (_storage[wordIndex] & mask) == 0
        _storage[wordIndex] |= mask
        return wasAbsent
    }
}

// MARK: - Remove

extension __SetIndexBitPacked {
    @inlinable
    @discardableResult
    public mutating func remove(_ member: Bit.Index) -> Bool {
        let wordIndex = member.position / Self._bitsPerWord
        guard wordIndex < _storage.count else { return false }
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex

        let wasPresent = (_storage[wordIndex] & mask) != 0
        _storage[wordIndex] &= ~mask
        return wasPresent
    }

    @inlinable
    public mutating func clear() {
        for i in 0..<_storage.count {
            _storage[i] = 0
        }
    }

    @inlinable
    public mutating func removeAll() {
        clear()
    }
}

extension __SetIndexBitPacked.Bounded {
    @inlinable
    @discardableResult
    public mutating func remove(_ member: Bit.Index) -> Bool {
        guard member.position < capacity else { return false }
        let wordIndex = member.position / Self._bitsPerWord
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex

        let wasPresent = (_storage[wordIndex] & mask) != 0
        _storage[wordIndex] &= ~mask
        return wasPresent
    }

    @inlinable
    public mutating func clear() {
        for i in 0..<_storage.count {
            _storage[i] = 0
        }
    }
}

extension __SetIndexBitPacked.Inline {
    @inlinable
    @discardableResult
    public mutating func remove(_ member: Bit.Index) -> Bool {
        guard member.position < Self.capacity else { return false }
        let wordIndex = member.position / Self._bitsPerWord
        let bitIndex = member.position % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex

        let wasPresent = (_storage[wordIndex] & mask) != 0
        _storage[wordIndex] &= ~mask
        return wasPresent
    }

    @inlinable
    public mutating func clear() {
        for i in 0..<wordCount {
            _storage[i] = 0
        }
    }
}

// MARK: - Set Operations

extension __SetIndexBitPacked {
    @inlinable
    public func union(_ other: __SetIndexBitPacked) -> __SetIndexBitPacked {
        var result = self
        result.formUnion(other)
        return result
    }

    @inlinable
    public mutating func formUnion(_ other: __SetIndexBitPacked) {
        if other._storage.count > _storage.count {
            _storage.reserveCapacity(other._storage.count)
            while _storage.count < other._storage.count {
                _storage.append(0)
            }
        }
        for i in 0..<other._storage.count {
            _storage[i] |= other._storage[i]
        }
    }

    @inlinable
    public func intersection(_ other: __SetIndexBitPacked) -> __SetIndexBitPacked {
        var result = self
        result.formIntersection(other)
        return result
    }

    @inlinable
    public mutating func formIntersection(_ other: __SetIndexBitPacked) {
        for i in 0..<_storage.count {
            if i < other._storage.count {
                _storage[i] &= other._storage[i]
            } else {
                _storage[i] = 0
            }
        }
    }

    @inlinable
    public func subtracting(_ other: __SetIndexBitPacked) -> __SetIndexBitPacked {
        var result = self
        result.subtract(other)
        return result
    }

    @inlinable
    public mutating func subtract(_ other: __SetIndexBitPacked) {
        for i in 0..<Swift.min(_storage.count, other._storage.count) {
            _storage[i] &= ~other._storage[i]
        }
    }

    @inlinable
    public func symmetricDifference(_ other: __SetIndexBitPacked) -> __SetIndexBitPacked {
        var result = self
        result.formSymmetricDifference(other)
        return result
    }

    @inlinable
    public mutating func formSymmetricDifference(_ other: __SetIndexBitPacked) {
        if other._storage.count > _storage.count {
            _storage.reserveCapacity(other._storage.count)
            while _storage.count < other._storage.count {
                _storage.append(0)
            }
        }
        for i in 0..<other._storage.count {
            _storage[i] ^= other._storage[i]
        }
    }

    @inlinable
    public func isSubset(of other: __SetIndexBitPacked) -> Bool {
        for (i, word) in _storage.enumerated() {
            let theirs = i < other._storage.count ? other._storage[i] : 0
            if word & ~theirs != 0 {
                return false
            }
        }
        return true
    }

    @inlinable
    public func isSuperset(of other: __SetIndexBitPacked) -> Bool {
        for (i, word) in other._storage.enumerated() {
            let mine = i < _storage.count ? _storage[i] : 0
            if word & ~mine != 0 {
                return false
            }
        }
        return true
    }

    @inlinable
    public func isDisjoint(with other: __SetIndexBitPacked) -> Bool {
        let minWords = Swift.min(_storage.count, other._storage.count)
        for i in 0..<minWords {
            if (_storage[i] & other._storage[i]) != 0 {
                return false
            }
        }
        return true
    }
}

extension __SetIndexBitPacked.Bounded {
    @inlinable
    public func union(_ other: __SetIndexBitPacked.Bounded) -> __SetIndexBitPacked.Bounded {
        precondition(capacity == other.capacity)
        var result = self
        for i in 0..<_storage.count {
            result._storage[i] |= other._storage[i]
        }
        return result
    }

    @inlinable
    public func intersection(_ other: __SetIndexBitPacked.Bounded) -> __SetIndexBitPacked.Bounded {
        precondition(capacity == other.capacity)
        var result = self
        for i in 0..<_storage.count {
            result._storage[i] &= other._storage[i]
        }
        return result
    }

    @inlinable
    public func subtracting(_ other: __SetIndexBitPacked.Bounded) -> __SetIndexBitPacked.Bounded {
        precondition(capacity == other.capacity)
        var result = self
        for i in 0..<_storage.count {
            result._storage[i] &= ~other._storage[i]
        }
        return result
    }

    @inlinable
    public func symmetricDifference(_ other: __SetIndexBitPacked.Bounded) -> __SetIndexBitPacked.Bounded {
        precondition(capacity == other.capacity)
        var result = self
        for i in 0..<_storage.count {
            result._storage[i] ^= other._storage[i]
        }
        return result
    }
}

extension __SetIndexBitPacked.Inline {
    @inlinable
    public func union(_ other: Self) -> Self {
        var result = self
        for i in 0..<wordCount {
            result._storage[i] |= other._storage[i]
        }
        return result
    }

    @inlinable
    public func intersection(_ other: Self) -> Self {
        var result = self
        for i in 0..<wordCount {
            result._storage[i] &= other._storage[i]
        }
        return result
    }

    @inlinable
    public func subtracting(_ other: Self) -> Self {
        var result = self
        for i in 0..<wordCount {
            result._storage[i] &= ~other._storage[i]
        }
        return result
    }

    @inlinable
    public func symmetricDifference(_ other: Self) -> Self {
        var result = self
        for i in 0..<wordCount {
            result._storage[i] ^= other._storage[i]
        }
        return result
    }
}

// MARK: - Iteration

extension __SetIndexBitPacked {
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        for (wordIndex, var word) in _storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let member = wordIndex * Self._bitsPerWord + bitIndex
                body(Bit.Index(member))
                word &= word - 1
            }
        }
    }
}

extension __SetIndexBitPacked.Bounded {
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        for (wordIndex, var word) in _storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let member = wordIndex * Self._bitsPerWord + bitIndex
                if member < capacity {
                    body(Bit.Index(member))
                }
                word &= word - 1
            }
        }
    }
}

extension __SetIndexBitPacked.Inline {
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        for wordIndex in 0..<wordCount {
            var word = _storage[wordIndex]
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let member = wordIndex * Self._bitsPerWord + bitIndex
                body(Bit.Index(member))
                word &= word - 1
            }
        }
    }
}

// MARK: - Equatable

extension __SetIndexBitPacked: Equatable {
    @inlinable
    public static func == (lhs: __SetIndexBitPacked, rhs: __SetIndexBitPacked) -> Bool {
        let maxWords = Swift.max(lhs._storage.count, rhs._storage.count)
        for i in 0..<maxWords {
            let a = i < lhs._storage.count ? lhs._storage[i] : 0
            let b = i < rhs._storage.count ? rhs._storage[i] : 0
            if a != b { return false }
        }
        return true
    }
}

extension __SetIndexBitPacked.Bounded: Equatable {}

extension __SetIndexBitPacked.Inline: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<wordCount {
            if lhs._storage[i] != rhs._storage[i] { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension __SetIndexBitPacked: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        var lastNonZero = _storage.count - 1
        while lastNonZero >= 0 && _storage[lastNonZero] == 0 {
            lastNonZero -= 1
        }
        hasher.combine(lastNonZero + 1)
        for i in 0...Swift.max(0, lastNonZero) {
            hasher.combine(_storage[i])
        }
    }
}

extension __SetIndexBitPacked.Bounded: Hashable {}

extension __SetIndexBitPacked.Inline: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<wordCount {
            hasher.combine(_storage[i])
        }
    }
}
