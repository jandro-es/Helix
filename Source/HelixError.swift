//
//  HelixError.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Extends Error type with custom errors for Helix
///
/// - graphDefinitionNotFound: When there is not a matching definition added to the Helix
/// - propertyInjectionFailed: When failed to inject property
/// - autoWiringFailed: When failed to autowire a type
/// - conflictGraphDefinition: When there are several definitions for the type with the same number of arguments (autowire)
/// - invalidType: The instance doesn't know how to deal with the forwarded type
public enum HelixError: Error, CustomStringConvertible {
    
    case graphDefinitionNotFound(key: GraphDefinitionKey)
    case propertyInjectionFailed(label: String?, type: Any.Type, underlyingError: Error)
    case autoWiringFailed(type: Any.Type, underlyingError: Error)
    case conflictGraphDefinition(type: Any.Type, definitions: [GraphDefinitionType])
    case invalidType(resolved: Any?, key: GraphDefinitionKey)
    
    public var description: String {
        switch self {
        case let .graphDefinitionNotFound(key):
            return "No GraphDefinition found with key: \(key.description) for type: \(key.type)"
        case let .propertyInjectionFailed(label, type, error):
            return "Injection of property \(label.desc) with type: \(type) failed with error: \(error)"
        case let .autoWiringFailed(type, error):
            return "Failed to auto-wire type \"\(type)\". \(error)"
        case let .conflictGraphDefinition(type, definitions):
            return "Conflicting GraphDefinitions (autowire) for \(type):\n" + definitions.map({ "\($0)" }).joined(separator: ";\n")
        case let .invalidType(resolved, key):
            return "Resolved instance \(resolved ?? "nil") does not implement expected type \(key.type)."
        }
    }
}
