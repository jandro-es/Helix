//
//  Context.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

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
