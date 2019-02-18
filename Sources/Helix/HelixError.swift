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
