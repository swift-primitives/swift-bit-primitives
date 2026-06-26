// Bit+Codable.swift
// Extends Bit and Bit.Order to conform to Swift.Codable.

import Bit_Primitive

#if !hasFeature(Embedded)
    extension Bit: Codable {}

    extension Bit.Order: Codable {
        /// Creates a bit order by decoding its string representation.
        ///
        /// - Parameter decoder: The decoder to read the `"msb"` or `"lsb"` value from.
        /// - Throws: A `DecodingError` if the decoded value is neither `"msb"` nor `"lsb"`.
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            switch value {
            case "msb": self = .msb
            case "lsb": self = .lsb

            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected 'msb' or 'lsb', got '\(value)'"
                )
            }
        }

        /// Encodes this bit order as its string representation.
        ///
        /// - Parameter encoder: The encoder to write the `"msb"` or `"lsb"` value to.
        /// - Throws: An error if the value cannot be encoded.
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .msb: try container.encode("msb")
            case .lsb: try container.encode("lsb")
            }
        }
    }
#endif
