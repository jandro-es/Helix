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

/// Defines a key for a GraphDefiniton
public struct GraphDefinitionKey {
    
    // MARK: - Public properties
    
    /// The type implemented by GraphDefinition
    public let type: Any.Type
    
    /// The type of the arguments
    public let typeOfArguments: Any.Type
    
    /// The tag for the GraphDefinition
    public internal(set) var tag: HelixTag?
    
    // MARK: - Initializers
    
    init(type: Any.Type, typeOfArguments: Any.Type, tag: HelixTag?) {
        self.type = type
        self.typeOfArguments = typeOfArguments
        self.tag = tag
    }
    
    // MARK: - Internal methods
    
    /// Tags the GraphDefinition with the given tag
    ///
    /// - Parameter tag: The tag to set
    /// - Returns: A mutated version of Self
    func tagged(with tag: HelixTag?) -> GraphDefinitionKey {
        var tagged = self
        tagged.tag = tag
        return tagged
    }
}

// MARK: - Hashable

extension GraphDefinitionKey: Hashable {
    
    public var hashValue: Int {
        return "key-\(type)-\(typeOfArguments)-\(tag.desc)".hashValue
    }
}

// MARK: - CustomStringConvertible

extension GraphDefinitionKey: CustomStringConvertible {
    
    public var description: String {
        return "GraphDefinitionKey for type: \(type) with tag: \(tag.desc)"
    }
}

// MARK: - CustomDebugStringConvertible

extension GraphDefinitionKey: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "GraphDefinitionKey for type: \(type) with tag: \(tag.desc)"
    }
}

// MARK: - Equatable

extension GraphDefinitionKey: Equatable {
    
    public static func == (lhs: GraphDefinitionKey, rhs: GraphDefinitionKey) -> Bool {
        return lhs.type == rhs.type && lhs.typeOfArguments == rhs.typeOfArguments && lhs.tag == rhs.tag
    }
}
