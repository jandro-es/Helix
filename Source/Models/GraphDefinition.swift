//
//  Definition.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Extends the GraphDefinitionType for autowiring
protocol AutoWiringGraphDefinition: GraphDefinitionType {
    var numberOfArguments: Int { get }
    var autoWiringFactory: ((Helix, HelixTag?) throws -> Any)? { get }
}

protocol ResolvingGraphDefinitionType: GraphDefinitionType {
    var implementingTypes: [Any.Type] { get }
    func knowsHowToImplement(type aType: Any.Type) -> Bool
}

protocol InternalResolvingGraphDefinitionType: InternalGraphDefinitionType {
    weak var resolvesWith: InternalResolvingGraphDefinitionType? { get }
    var resolvesFrom: [InternalResolvingGraphDefinitionType] { get set }
    func implements(type aType: Any.Type)
    func implements(types aTypes: [Any.Type])
}

/// Protocol with internal properties and methods for a GraphDefinitionType
protocol InternalGraphDefinitionType: AutoWiringGraphDefinition, ResolvingGraphDefinitionType {
    
    var helix: Helix? { get set }
    var type: Any.Type { get }
    var creationScope: CreationScope { get }
    var weakFactory: ((Any) throws -> Any)! { get }
    func resolveProperties(of item: Any, helix: Helix) throws
}

/// Empty class protocol to allow public methods
public protocol GraphDefinitionType: class {}

public final class GraphDefinition<T, U>: GraphDefinitionType {
    
    // MARK: - Typealias
    
    /// Typealias for a Factory lambda which
    /// receives a type U and returns a type T
    public typealias Factory = (U) throws -> T
    
    // MARK: - Internal properties
    
    /// Storage for the Factory function of the GraphDefinition
    let factory: Factory
    
    /// Lambda to resolve properties receiving a Helix instance and Any type
    var resolvePropertiesLambda: ((Helix, Any) throws -> Void)?
    
    // MARK: - InternalGraphDefinitionType
    
    /// Weak reference to the Helix object using this GraphDefinition
    weak var helix: Helix?
    
    /// The creation scope of the item created with this GraphDefinition
    public internal(set) var creationScope: CreationScope
    
    /// A weak reference to this GraphDefinition factory
    var weakFactory: ((Any) throws -> Any)!
    
    // MARK: - AutoWiringGraphDefinition
    
    var autoWiringFactory: ((Helix, HelixTag?) throws -> Any)?
    var numberOfArguments: Int = 0
    
    // MARK: - ResolvingGraphDefinitionType
    
    /// The types this GraphDefinition implements
    private(set) var implementingTypes: [Any.Type] = [(T?).self, (T!).self]
    
    // MARK: - InternalResolvingGraphDefinitionType
    
    /// Other GraphDefinition needed to resolve this GraphDefinition
    weak var resolvesWith: InternalResolvingGraphDefinitionType? {
        didSet {
            if let resolvesWith = resolvesWith {
                // This GraphDefinition can resolve the type and the implementing types
                // of the collaborating one
                implements(type: resolvesWith.type)
                implements(types: resolvesWith.implementingTypes)
                // The GraphDefinitions that are resolved by the collaborating one
                // can resolve the type and implementing
                // types of this GraphDefinition
                // This helps reusing already resolved instances
                resolvesWith.resolvesFrom.forEach({
                    $0.implements(type: type)
                    $0.implements(types: implementingTypes)
                })
                // The collaborating GraphDefinition can resolve the type and implementing types
                // of this GraphDefinition
                resolvesWith.implements(type: type)
                resolvesWith.implements(types: implementingTypes)
                // The collaborating GraphDefinition resolves this GraphDefinition
                resolvesWith.resolvesFrom.append(self)
            }
        }
    }
    
    /// GraphDefinitions that needs this GraphDefinition to be resolved
    var resolvesFrom: [InternalResolvingGraphDefinitionType] = []
    
    // MARK: - Initializers
    
    /// Creates a GraphDefinition with the given creation scope and the given
    /// Factory function
    ///
    /// - Parameters:
    ///   - creationScope: The creation scope to use for the instance
    ///   - factory: The Factory function
    init(creationScope: CreationScope, factory: @escaping Factory) {
        self.factory = factory
        self.creationScope = creationScope
    }
    
    // MARK: - Public methods

    /// Adds a lambda to resolve properties to the GraphDefinition, if the GraphDefinition
    /// already have one or more lambdas it adds the new lambda to the queue maintaining the
    /// order.
    /// When having circular dependencies at least one of the dependencies need to use
    /// this method to resolve it.
    ///
    /// - Parameter lambda: The new lambda to resolve properties
    @discardableResult public func resolvingProperties(_ lambda: @escaping (Helix, T) throws -> Void) -> GraphDefinition {
        guard let existingResolvePropertiesLambda = resolvePropertiesLambda else {
            resolvePropertiesLambda = { try lambda($0, $1 as! T) }
            return self
        }
        resolvePropertiesLambda! = {
            try existingResolvePropertiesLambda($0, $1 as! T)
            try lambda($0, $1 as! T)
        }
        return self
    }
    
    // MARK: - InternalGraphDefinitionType
    
    /// Resolves the properties of the given item, using the passed Helix object
    ///
    /// - Parameters:
    ///   - item: The item to resolve
    ///   - helix: The Helix object to use for the resolution
    /// - Throws: Error while resolving
    func resolveProperties(of item: Any, helix: Helix) throws {
        guard let resolvedItem = item as? T else {
            return
        }
        if let resolvesWith = resolvesWith {
            try resolvesWith.resolveProperties(of: resolvedItem, helix: helix)
        }
        if let resolvePropertiesLambda = resolvePropertiesLambda {
            try resolvePropertiesLambda(helix, resolvedItem)
        }
    }
    
    // MARK: - ResolvingGraphDefinitionType
    
    /// Returns true if this GraphDefinition knows how to implement
    /// the specified type
    ///
    /// - Parameter theType: The type
    /// - Returns: True if the GraphDefinition knows how to implement it
    func knowsHowToImplement(type theType: Any.Type) -> Bool {
        return implementingTypes.contains(where: { $0 == theType })
    }
    
    // MARK: - InternalResolvingGraphDefinitionType
    
    /// Adds the given type to the list of types this GraphDefinition
    /// knows how to implement
    ///
    /// - Parameter theType: The type to add
    func implements(type theType: Any.Type) {
        implements(types: [theType])
    }
    
    /// Adds a collection of types to the list of types
    /// being able to implement avoiding duplications
    ///
    /// - Parameter theTypes: The collection of types
    func implements(types theTypes: [Any.Type]) {
        implementingTypes.append(contentsOf: theTypes.filter({ knowsHowToImplement(type: $0) == false }))
    }

    /// Registers the definition for the given type in the Helix object. It requires the Helix object
    /// to be present.
    ///
    /// - Parameters:
    ///   - type: The type to register the definition for
    ///   - tag: The tag to identify the definition
    /// - Returns: The definition itself
    @discardableResult public func solves<F>(_ type: F.Type, tag: HelixTaggable? = nil) -> GraphDefinition {
        guard let helix = helix else {
            fatalError("A Helix object needs to be present")
        }
        helix.add(graphDefinition: self, type: type, tag: tag)
        return self
    }

    /// Registers the definition for the given type in the Helix object with a lambda to resolve it's properties.
    ///
    /// - Parameters:
    ///   - type: The type to register the definition for
    ///   - tag: The tag to identify the definition
    ///   - resolvingProperties: Lambda to resolve the properties of the type
    /// - Returns: The definition itself
    @discardableResult public func solves<F>(_ type: F.Type, tag: HelixTaggable? = nil, resolvingProperties: @escaping (Helix, F) throws -> ()) -> GraphDefinition {
        guard let helix = helix else {
            fatalError("A Helix object needs to be present")
        }
        let forwardDefinition = helix.add(graphDefinition: self, type: type, tag: tag)
        forwardDefinition.resolvingProperties(resolvingProperties)
        return self
    }
    
    /// Registers a definition for two types
    ///
    /// - Parameters:
    ///   - first: First type
    ///   - second: Second type
    /// - Returns: The definition itself
    @discardableResult public func solves<A, B>(_ first: A.Type, _ second: B.Type) -> GraphDefinition {
        return solves(first).solves(second)
    }
    
    /// Registers a definition for three types
    ///
    /// - Parameters:
    ///   - first: The first type
    ///   - second: The second type
    ///   - third: The third type
    /// - Returns: The definition itself
    @discardableResult public func solves<A, B, C>(_ first: A.Type, _ second: B.Type, _ third: C.Type) -> GraphDefinition {
        return solves(first).solves(second).solves(third)
    }
    
    /// Registers a definition for four types
    ///
    /// - Parameters:
    ///   - first: The first type
    ///   - second: The second type
    ///   - third: The third type
    ///   - fourth: The fourth type
    /// - Returns: The definition itself
    @discardableResult public func solves<A, B, C, D>(_ first: A.Type, _ second: B.Type, _ third: C.Type, _ fourth: D.Type) -> GraphDefinition {
        return solves(first).solves(second).solves(third).solves(fourth)
    }
    
    /// Registers a definition for five types
    ///
    /// - Parameters:
    ///   - first: The first type
    ///   - second: The second type
    ///   - third: The third type
    ///   - fourth: The fourth type
    ///   - fifth: The fifth type
    /// - Returns: The definition itself
    @discardableResult public func solves<A, B, C, D, E>(_ first: A.Type, _ second: B.Type, _ third: C.Type, _ fourth: D.Type, _ fifth: E.Type) -> GraphDefinition {
        return solves(first).solves(second).solves(third).solves(fourth).solves(fifth)
    }
    
    /// Registers a definition for six types
    ///
    /// - Parameters:
    ///   - first: The first type
    ///   - second: The second type
    ///   - third: The third type
    ///   - fourth: The fourth type
    ///   - fifth: The fifth type
    ///   - sixth: The sixth type
    /// - Returns: The definition itself
    @discardableResult public func solves<A, B, C, D, E, F>(_ first: A.Type, _ second: B.Type, _ third: C.Type, _ fourth: D.Type, _ fifth: E.Type, _ sixth: F.Type) -> GraphDefinition {
        return solves(first).solves(second).solves(third).solves(fourth).solves(fifth).solves(sixth)
    }
}

// MARK: - InternalResolvingGraphDefinitionType

extension GraphDefinition: InternalResolvingGraphDefinitionType {
    
    /// The type of the GraphDefinition
    var type: Any.Type {
        return T.self
    }
}

// MARK: - CustomStringConvertible

extension GraphDefinition: CustomStringConvertible {
    
    public var description: String {
        return "GraphDefinition object for type: \(T.self) with creation scope: \(creationScope) and numberOfArguments: \(numberOfArguments)"
    }
}

// MARK: - CustomDebugStringConvertible

extension GraphDefinition: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "GraphDefinition object for type: \(T.self) with creation scope: \(creationScope) and numberOfArguments: \(numberOfArguments)"
    }
}
