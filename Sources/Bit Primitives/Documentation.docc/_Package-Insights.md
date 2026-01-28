# Bit Primitives Insights

<!--
---
title: Bit Primitives Insights
version: 1.0.0
last_updated: 2026-01-28
applies_to: [swift-bit-primitives]
normative: false
---
-->

@Metadata {
    @TitleHeading("Bit Primitives")
}

Design decisions, implementation patterns, and lessons learned specific to this package.

## Overview

This document captures insights that emerged during development of swift-bit-primitives. These are not API requirements—they are recorded decisions and patterns that inform future work on this package.

**Document type**: Non-normative (recorded decisions, not requirements).

**Consolidation source**: Reflection entries tagged with `[Package: swift-bit-primitives]`.

---

## Build Error Messages as Exploration Seeds

**Date**: 2026-01-27

**Context**: The array-primitives build failure revealed the bit-primitives issue through dependency chain.

The build command was `swift build` in swift-array-primitives. The error was in swift-bit-primitives. This distance between command and failure reveals the dependency chain: array-primitives → heap-primitives → bit-primitives (or similar). Build errors in unexpected packages often signal unexplored territory.

The bit-primitives failure wasn't on the task list—we were focused on array-primitives strided access. But the build system doesn't respect task lists. The error demanded attention, leading to analysis of the `ExpressibleByIntegerLiteral` constraint, which unblocked the original array-primitives build.

This could be dismissed as yak shaving—we started with array subscripts and ended analyzing affine geometry. But each step was necessary. The strided access refactoring required builds to pass. The builds required bit-primitives to compile. Purpose-driven tangents are not distractions; they're the real work.

**Applies to**: Transitive dependency failures, build error investigation, following error chains.

---

## Generic Word Types as Principled Consistency

**Date**: 2026-01-27

**Context**: Refactoring `Location` and `Storage` to be generic over the word type with fully typed fields.

The session reached a turning point when, after proposing `Location<Word>` with typed `word: Index<Word>` and `bit: Index<Bit>.Offset`, the suggestion to keep `mask: Word` as the only untyped field was challenged: "we use typed everywhere so why not here too?"

This is the right instinct. Consistency isn't about following rules—it's about not creating arbitrary exceptions. If the ecosystem uses `Index<T>` for indices, `Index<T>.Offset` for offsets, and `Index<T>.Count` for counts, then every index-like, offset-like, and count-like value should use these types.

Making `Location` generic over `Word` immediately surfaced a Sendable constraint issue. The type declared `Sendable` but stored a generic `Word` with no Sendable constraint. The fix: add `& Sendable` to the generic constraint. This is constraint propagation working correctly.

The full refactoring changed:
- `word: Int` → `word: Index<Word>`
- `bit: Int` → `bit: Index<Bit>.Offset`
- `bitsPerWord: Int` → `bitsPerWord: Affine.Discrete.Ratio<Word, Bit>`
- `wordCount: Int` → `wordCount: Index<Word>.Count`
- `unusedBits: Int` → `unusedBits: Index<Bit>.Count`

Every `Int` had a more precise type waiting to replace it. The typed versions are self-documenting.

**Applies to**: `Bit.Location<Word>`, `Bit.Storage<Word>`, typed field consistency, constraint propagation.

---

## Topics

### Related Documents

- <doc:Bit-Location>
- <doc:Bit-Storage>
