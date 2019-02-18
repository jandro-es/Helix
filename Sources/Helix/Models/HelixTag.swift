// The MIT License
//
// Copyright (c) 2018-2019 Alejandro Barros Cuetos. jandro@filtercode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
