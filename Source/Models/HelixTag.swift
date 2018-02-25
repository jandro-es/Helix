//
//  HelixTag.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Represents a way of tagging every dependency. A tag can be a String or
/// a Int
///
/// - String: Tag using a StringLiteral
/// - Int: Tag using a IntLiteral
public enum HelixTag {
    case String(StringLiteralType)
    case Int(IntegerLiteralType)
}

// MARK: - ExpressibleByStringLiteral

extension HelixTag: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self = .String(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension HelixTag: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Int(value)
    }
}

// MARK: - Equatable

extension HelixTag: Equatable {
    
    public static func == (lhs: HelixTag, rhs: HelixTag) -> Bool {
        switch (lhs, rhs) {
        case let (.String(lhsString), .String(rhsString)):
            return lhsString == rhsString
        case let (.Int(lhsInt), .Int(rhsInt)):
            return lhsInt == rhsInt
        default:
            return false
        }
    }
}

// MARK: - DependencyTagConvertible

extension HelixTag: HelixTaggable {
    
    public var dependencyTag: HelixTag {
        return self
    }
}
