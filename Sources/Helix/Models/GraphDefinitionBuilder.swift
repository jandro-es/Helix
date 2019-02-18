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
        return "GraphDefinitionBuilder: creationScope: \(String(describing: creationScope)) - factory: \(String(describing: factory)) - wiringFactory: \(String(describing: wiringFactory)) - number of arguments: \(numberOfArguments) - resolvesWith: \(String(describing: resolvesWith))"
    }
}

extension GraphDefinitionBuilder: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "GraphDefinitionBuilder: creationScope: \(String(describing: creationScope)) - factory: \(String(describing: factory)) - wiringFactory: \(String(describing: wiringFactory)) - number of arguments: \(numberOfArguments) - resolvesWith: \(String(describing: resolvesWith))"
    }
}
