# Bit Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-primitives/swift-bit-primitives/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-primitives/swift-bit-primitives/actions/workflows/ci.yml)

`Bit` — a binary-digit value type with `.zero` / `.one` cases — and the complete two-element Boolean algebra (`&`, `|`, `^`, `~`, plus NAND / NOR / XNOR / AND-NOT) and Z₂ field (`+` is XOR, `×` is AND) defined over it. `@frozen`, `Sendable`, and `UInt8`-backed, with conformances to the institute's `Comparison.Protocol`, `Equation.Protocol`, and `Hash.Protocol` alongside the matching Swift stdlib protocols.

A dedicated `Bit` type makes the {0, 1} domain a compile-time fact rather than a convention layered over `Bool` or a raw integer, and carries the algebraic structure that `swift-bit-vector-primitives` and GF(2) linear algebra build on.

---

## Key Features

- **Binary-digit value type** — A two-case `Bit` enum (`.zero` / `.one`) instead of `Bool` or a raw `UInt8`: the type system enforces the domain, and the operations carry algebraic structure that neither `Bool` nor `Int` expresses directly.
- **Full Boolean operation set** — `&` / `|` / `^` / `~` and prefix `!` operators, method forms (`.and`, `.or`, `.xor`, `.flipped` / `.toggled`), and the compound operations NAND, NOR, XNOR, and AND-NOT.
- **Z₂ field arithmetic** — `.adding` (XOR) and multiplication (AND) realize the two-element field ⟨{0, 1}, +, ×⟩ — the algebraic foundation for bit-vectors and GF(2) work.
- **Bit ordering** — `Bit.Order` names the most-significant-first vs least-significant-first convention (with `msb` / `lsb` aliases) for packing bits into wider words.
- **Stdlib-fluent** — `ExpressibleByBooleanLiteral` and `ExpressibleByIntegerLiteral` let you write `let b: Bit = true` or `let b: Bit = 1`; `Comparable`, `Codable`, `CaseIterable`, and `CustomStringConvertible` round out the surface.

---

## Quick Start

```swift
import Bit_Primitives

let a: Bit = .one
let b: Bit = .zero

a ^ b        // .one   — XOR, addition in Z₂
a & b        // .zero  — AND, multiplication in Z₂
a | b        // .one   — OR
~a           // .zero  — complement
```

Method forms read left-to-right and the Z₂ field operations name the algebra explicitly:

```swift
a.xor(b)         // .one
a.and(b)         // .zero
a.adding(b)      // .one   — Z₂ field addition (XOR)
a.flipped        // .zero  — NOT
```

Literals and checked construction:

```swift
let on: Bit = true      // .one   (ExpressibleByBooleanLiteral)
let off: Bit = 0        // .zero  (ExpressibleByIntegerLiteral)
Bit(2)                  // nil    — only 0 and 1 are valid
```

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-bit-primitives.git", branch: "main")
]
```

Add the umbrella product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Bit Primitives", package: "swift-bit-primitives")
    ]
)
```

For just the value type and its operations without the stdlib bridge or institute-protocol conformances, depend on `Bit Primitive` alone.

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

Three library products plus a Test Support target:

| Product | Contents | When to import |
|---------|----------|----------------|
| `Bit Primitives` | Umbrella — `Bit` value type, all operations, the `Comparison` / `Equation` / `Hash` protocol conformances, and the stdlib integration | Most consumers |
| `Bit Primitive` | The `Bit` enum, `Bit.Order`, and the Boolean / compound / Z₂ / bitwise operations (no stdlib bridge, no institute-protocol conformances) | Minimal surface |
| `Bit Primitives Standard Library Integration` | `Comparable`, `Codable`, `CaseIterable`, `ExpressibleBy*Literal`, `CustomStringConvertible`, and `Cardinal`-typed shift operators on `FixedWidthInteger` | Pulled in transitively by the umbrella |
| `Bit Primitives Test Support` | Re-export of upstream Test Support modules | Test target only |

---

## Stability

Pre-1.0. The 0.1.0 surface — the `Bit` enum, its Boolean / compound / Z₂ operations, `Bit.Order`, and the `Comparison` / `Equation` / `Hash` conformances — is committed to source-compatibility. `Bit` is `@frozen`: its two-case, `UInt8`-backed layout is permanent.

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | —   | Supported    |

---

## Related Packages

- [`swift-comparison-primitives`](https://github.com/swift-primitives/swift-comparison-primitives) — `Comparison.Protocol`, which `Bit` conforms to.
- [`swift-equation-primitives`](https://github.com/swift-primitives/swift-equation-primitives) — `Equation.Protocol`, the equality protocol `Comparison.Protocol` refines.
- [`swift-hash-primitives`](https://github.com/swift-primitives/swift-hash-primitives) — `Hash.Protocol`, which `Bit` conforms to.
- [`swift-cardinal-primitives`](https://github.com/swift-primitives/swift-cardinal-primitives) — `Cardinal`, used by the typed shift operators in the Standard Library Integration product.
- [`swift-carrier-primitives`](https://github.com/swift-primitives/swift-carrier-primitives) — `Carrier`, the phantom-typed wrapper those shift operators range over.

---

## Community

<!-- BEGIN: discussion -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
