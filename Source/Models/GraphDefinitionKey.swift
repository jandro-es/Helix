//
//  DefinitionKey.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

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
