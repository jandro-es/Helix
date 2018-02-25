//
//  DefinitionBuilder.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Class to build a GraphDefinition
final class GraphDefinitionBuilder<T, U> {
    
    // MARK: - Typealias
    
    typealias Factory = (U) throws -> T
    typealias WiringFactory = (Helix, HelixTag?) throws -> T
    
    // MARK: - Properties
    
    /// The creation scope to use
    var creationScope: CreationScope!
    
    /// The Factory function to create the GraphDefinition
    var factory: Factory!
    
    /// The wiring factory for the autowiring for the GraphDefinition
    var wiringFactory: WiringFactory?
    
    /// The number of arguments
    var numberOfArguments: Int = 0
    
    /// Collaborating GraphDefinition for resolving
    var resolvesWith: InternalGraphDefinitionType?
    
    // MARK: - Initializer
    
    init(_ configure: (GraphDefinitionBuilder) -> Void) {
        configure(self)
    }
    
    // MARK: - Builder methods
    
    /// Initializes and confures a GraphDefinition
    ///
    /// - Returns: The created GraphDefinition
    func build() -> GraphDefinition<T, U> {
        let factory = self.factory!
        let graphDefinition = GraphDefinition<T, U>(creationScope: creationScope, factory: factory)
        graphDefinition.resolvesWith = resolvesWith as? InternalResolvingGraphDefinitionType
        graphDefinition.autoWiringFactory = wiringFactory
        graphDefinition.numberOfArguments = numberOfArguments
        graphDefinition.weakFactory = { try factory($0 as! U) }
        
        return graphDefinition
    }
}

extension GraphDefinitionBuilder: CustomStringConvertible {
    
    var description: String {
        return "GraphDefinitionBuilder: creationScope: \(creationScope) - factory: \(factory) - wiringFactory: \(String(describing: wiringFactory)) - number of arguments: \(numberOfArguments) - resolvesWith: \(String(describing: resolvesWith))"
    }
}

extension GraphDefinitionBuilder: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "GraphDefinitionBuilder: creationScope: \(creationScope) - factory: \(factory) - wiringFactory: \(String(describing: wiringFactory)) - number of arguments: \(numberOfArguments) - resolvesWith: \(String(describing: resolvesWith))"
    }
}
