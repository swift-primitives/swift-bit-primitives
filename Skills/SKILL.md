---
name: bit-primitives
description: |
  Bit manipulation primitives for low-level operations.
  ALWAYS apply when working with bitwise operations.

layer: implementation

requires:
  - primitives

applies_to:
  - swift
  - swift-primitives
  - swift-bit-primitives
---

# Bit Primitives

Bit manipulation and extension patterns.

---

## Core Design Decisions

### [BIT-001] Extension Patterns

**Statement**: Bit operations MUST use consistent extension patterns across integer types.

---

## Cross-References

Full analysis: `Research/Bit Primitives Extension Patterns Analysis.md`
