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

/// Set of non-negative integers represented as bit flags.
///
/// `Bit.Set` represents a set of non-negative integers using a bit vector,
/// where each bit indicates whether the corresponding integer is a member.
/// This is extremely efficient for dense sets of small integers.
///
/// ## Example
///
/// ```swift
/// var set = Bit.Set()
/// set.insert(5)
/// set.insert(10)
/// set.contains(5)    // true
/// set.contains(7)    // false
/// set.count          // 2
/// ```
///
/// ## Set Operations
///
/// Standard set operations are provided as efficient bitwise operations:
///
/// ```swift
/// let a = Bit.Set([1, 2, 3])
/// let b = Bit.Set([2, 3, 4])
/// a.union(b)         // {1, 2, 3, 4}
/// a.intersection(b)  // {2, 3}
/// a.symmetricDifference(b)  // {1, 4}
/// ```
extension Bit {
    public struct Set: Sendable {
        /// Bits per storage word.
        @usableFromInline
        static var _bitsPerWord: Int { UInt.bitWidth }

        /// Storage for bit words.
        @usableFromInline
        var _storage: ContiguousArray<UInt>

        /// Creates an empty bit set.
        @inlinable
        public init() {
            self._storage = []
        }

        /// Creates a bit set containing the given members.
        @inlinable
        public init(_ members: some Sequence<Int>) {
            self.init()
            for member in members {
                insert(member)
            }
        }
    }
}

// MARK: - Properties

extension Bit.Set {
    /// The number of members in the set.
    @inlinable
    public var count: Int {
        var total = 0
        for word in _storage {
            total += word.nonzeroBitCount
        }
        return total
    }

    /// Whether the set is empty.
    @inlinable
    public var isEmpty: Bool {
        for word in _storage {
            if word != 0 {
                return false
            }
        }
        return true
    }

    /// The maximum member in the set, or nil if empty.
    @inlinable
    public var max: Int? {
        for i in stride(from: _storage.count - 1, through: 0, by: -1) {
            let word = _storage[i]
            if word != 0 {
                let bitIndex = UInt.bitWidth - 1 - word.leadingZeroBitCount
                return i * Self._bitsPerWord + bitIndex
            }
        }
        return nil
    }

    /// The minimum member in the set, or nil if empty.
    @inlinable
    public var min: Int? {
        for (i, word) in _storage.enumerated() {
            if word != 0 {
                return i * Self._bitsPerWord + word.trailingZeroBitCount
            }
        }
        return nil
    }
}

// MARK: - Membership

extension Bit.Set {
    /// Returns whether the set contains the given member.
    @inlinable
    public func contains(_ member: Int) -> Bool {
        precondition(member >= 0, "Member must be non-negative")
        let wordIndex = member / Self._bitsPerWord
        guard wordIndex < _storage.count else { return false }
        let bitIndex = member % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (_storage[wordIndex] & mask) != 0
    }

    /// Inserts a member into the set.
    ///
    /// - Returns: `true` if the member was newly inserted, `false` if already present.
    @inlinable
    @discardableResult
    public mutating func insert(_ member: Int) -> Bool {
        precondition(member >= 0, "Member must be non-negative")
        let wordIndex = member / Self._bitsPerWord

        // Grow if needed
        if wordIndex >= _storage.count {
            _storage.append(contentsOf: repeatElement(0 as UInt, count: wordIndex + 1 - _storage.count))
        }

        let bitIndex = member % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasPresent = (_storage[wordIndex] & mask) != 0
        _storage[wordIndex] |= mask
        return !wasPresent
    }

    /// Removes a member from the set.
    ///
    /// - Returns: `true` if the member was removed, `false` if not present.
    @inlinable
    @discardableResult
    public mutating func remove(_ member: Int) -> Bool {
        precondition(member >= 0, "Member must be non-negative")
        let wordIndex = member / Self._bitsPerWord
        guard wordIndex < _storage.count else { return false }
        let bitIndex = member % Self._bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasPresent = (_storage[wordIndex] & mask) != 0
        _storage[wordIndex] &= ~mask
        return wasPresent
    }

    /// Removes all members from the set.
    @inlinable
    public mutating func removeAll() {
        for i in 0..<_storage.count {
            _storage[i] = 0
        }
    }
}

// MARK: - Set Operations

extension Bit.Set {
    /// Returns a new set containing the union of this set and another.
    @inlinable
    public func union(_ other: Bit.Set) -> Bit.Set {
        var result = Bit.Set()
        let maxWords = Swift.max(_storage.count, other._storage.count)
        result._storage.reserveCapacity(maxWords)

        for i in 0..<maxWords {
            let a = i < _storage.count ? _storage[i] : 0
            let b = i < other._storage.count ? other._storage[i] : 0
            result._storage.append(a | b)
        }

        return result
    }

    /// Returns a new set containing the intersection of this set and another.
    @inlinable
    public func intersection(_ other: Bit.Set) -> Bit.Set {
        var result = Bit.Set()
        let minWords = Swift.min(_storage.count, other._storage.count)
        result._storage.reserveCapacity(minWords)

        for i in 0..<minWords {
            result._storage.append(_storage[i] & other._storage[i])
        }

        return result
    }

    /// Returns a new set containing the symmetric difference of this set and another.
    @inlinable
    public func symmetricDifference(_ other: Bit.Set) -> Bit.Set {
        var result = Bit.Set()
        let maxWords = Swift.max(_storage.count, other._storage.count)
        result._storage.reserveCapacity(maxWords)

        for i in 0..<maxWords {
            let a = i < _storage.count ? _storage[i] : 0
            let b = i < other._storage.count ? other._storage[i] : 0
            result._storage.append(a ^ b)
        }

        return result
    }

    /// Returns a new set containing members in this set but not in another.
    @inlinable
    public func subtracting(_ other: Bit.Set) -> Bit.Set {
        var result = Bit.Set()
        result._storage.reserveCapacity(_storage.count)

        let minWords = Swift.min(_storage.count, other._storage.count)
        for i in 0..<minWords {
            result._storage.append(_storage[i] & ~other._storage[i])
        }
        for i in minWords..<_storage.count {
            result._storage.append(_storage[i])
        }

        return result
    }

    /// Returns whether this set is a subset of another.
    @inlinable
    public func isSubset(of other: Bit.Set) -> Bool {
        for (i, word) in _storage.enumerated() {
            let theirs = i < other._storage.count ? other._storage[i] : 0
            if word & ~theirs != 0 {
                return false
            }
        }
        return true
    }

    /// Returns whether this set is a superset of another.
    @inlinable
    public func isSuperset(of other: Bit.Set) -> Bool {
        for (i, word) in other._storage.enumerated() {
            let mine = i < _storage.count ? _storage[i] : 0
            if word & ~mine != 0 {
                return false
            }
        }
        return true
    }

    /// Returns whether this set and another are disjoint (have no common members).
    @inlinable
    public func isDisjoint(with other: Bit.Set) -> Bool {
        let minWords = Swift.min(_storage.count, other._storage.count)
        for i in 0..<minWords {
            if (_storage[i] & other._storage[i]) != 0 {
                return false
            }
        }
        return true
    }
}

// MARK: - Mutating Set Operations

extension Bit.Set {
    /// Forms the union with another set in place.
    @inlinable
    public mutating func formUnion(_ other: Bit.Set) {
        if other._storage.count > _storage.count {
            _storage.append(contentsOf: repeatElement(0 as UInt, count: other._storage.count - _storage.count))
        }

        for i in 0..<other._storage.count {
            _storage[i] |= other._storage[i]
        }
    }

    /// Forms the intersection with another set in place.
    @inlinable
    public mutating func formIntersection(_ other: Bit.Set) {
        let minWords = Swift.min(_storage.count, other._storage.count)
        for i in 0..<minWords {
            _storage[i] &= other._storage[i]
        }
        // Clear words beyond other's range
        for i in minWords..<_storage.count {
            _storage[i] = 0
        }
    }

    /// Forms the symmetric difference with another set in place.
    @inlinable
    public mutating func formSymmetricDifference(_ other: Bit.Set) {
        if other._storage.count > _storage.count {
            _storage.append(contentsOf: repeatElement(0 as UInt, count: other._storage.count - _storage.count))
        }

        for i in 0..<other._storage.count {
            _storage[i] ^= other._storage[i]
        }
    }

    /// Subtracts another set in place.
    @inlinable
    public mutating func subtract(_ other: Bit.Set) {
        let minWords = Swift.min(_storage.count, other._storage.count)
        for i in 0..<minWords {
            _storage[i] &= ~other._storage[i]
        }
    }
}

// MARK: - Iteration

extension Bit.Set {
    /// Calls the given closure for each member in the set.
    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        for (wordIndex, var word) in _storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                body(wordIndex * Self._bitsPerWord + bitIndex)
                word &= word - 1  // Clear lowest set bit
            }
        }
    }
}

// MARK: - Equatable

extension Bit.Set: Equatable {
    @inlinable
    public static func == (lhs: Bit.Set, rhs: Bit.Set) -> Bool {
        let maxWords = Swift.max(lhs._storage.count, rhs._storage.count)
        for i in 0..<maxWords {
            let a = i < lhs._storage.count ? lhs._storage[i] : 0
            let b = i < rhs._storage.count ? rhs._storage[i] : 0
            if a != b { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension Bit.Set: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        // Skip trailing zero words for consistent hashing
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
