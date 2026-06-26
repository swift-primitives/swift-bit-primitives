// Bit+Comparison.Protocol.swift
// Extends Bit to conform to Comparison.Protocol.
//
// Under Swift 6.4+, `Comparison.\`Protocol\`` is a typealias to
// `Swift.Comparable` per SE-0499. The Standard Library Integration
// target already declares `extension Bit: Swift.Comparable` (the `<`
// operator definition lives there), so this conformance is
// redundant under 6.4+. Guard to <6.4 only.

public import Comparison_Primitives

#if swift(<6.4)
    extension Bit: Comparison.`Protocol` {}
#endif
