// Bit+Hash.Protocol.swift
// Extends Bit to conform to Hash.Protocol.

public import Hash_Primitives

// Bit already conforms to Swift.Hashable, so it has the required
// == and hash(into:) methods. This conformance is trivial.
extension Bit: Hash.`Protocol` {}
