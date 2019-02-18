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

/// Represents the context for resolving a dependency
public struct ResolvingContext {
    
    // MARK: - Public properties
    
    /// The type currently being resolved
    public var typeBeingResolved: Any.Type {
        return key.type
    }
    
    /// The tag for resolving the current type
    public var resolvingTag: HelixTag? {
        return key.tag
    }
    
    /// The type that triggered to resolve this one
    public private(set) var neededByType: Any.Type?
    
    /// The property that triggered to resolve this one
    public private(set) var neededByProperty: String?
    
    /// The Helix object that triggered this context
    public private(set) var helix: Helix
    
    /// The GraphDefinitionKey of the object graph use to resolve
    public internal(set) var key: GraphDefinitionKey
    
    // MARK: - Internal properties
    
    /// If the resolution is independent or collaborating with
    /// other resolutions
    let isCollaborating: Bool
    
    // MARK: - Initializers
    
    /// Creates a resolving context with the given data
    ///
    /// - Parameters:
    ///   - key: The GraphDefinitionKey associated with the context
    ///   - neededByType: The type that needs the context if that's the case
    ///   - neededByProperty: The property that needs the context if that's the case
    ///   - isCollaborating: Is the context collaborating with another one?
    ///   - helix: The Helix that will use the context
    init(key: GraphDefinitionKey, neededByType: Any.Type?, neededByProperty: String?, isCollaborating: Bool, helix: Helix) {
        self.key = key
        self.neededByType = neededByType
        self.neededByProperty = neededByProperty
        self.isCollaborating = isCollaborating
        self.helix = helix
    }
}

// MARK: - CustomStringConvertible

extension ResolvingContext: CustomStringConvertible {
    
    public var description: String {
        return "Resolving context with key: \(key), neededByType: \(neededByType.desc) or neededByproperty: \(neededByProperty.desc) with collaboration: \(isCollaborating)"
    }
}

// MARK: - CustomDebugStringConvertible

extension ResolvingContext: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "Resolving context with key: \(key), neededByType: \(neededByType.desc) or neededByproperty: \(neededByProperty.desc) with collaboration: \(isCollaborating)"
    }
}
