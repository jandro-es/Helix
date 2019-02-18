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

/// Tuple grouping together a GraphDefinitionKey and InternalGraphDefinitionType
typealias GraphObjectDefinitionTuple = (graphDefinitionKey: GraphDefinitionKey, graphDefinition: InternalGraphDefinitionType)

// MARK: - Operations

/// Definitions are matched if they are registered for the same tag and thier factories accept the same number of runtime arguments.

/// Match operator for GraphObjectDefinitionTuple
///
/// - Parameters:
///   - lhs: a GraphObjectDefinitionTuple
///   - rhs: another GraphObjectDefinitionTuple
/// - Returns: If they can be matched or not
private func ~= (lhs: GraphObjectDefinitionTuple, rhs: GraphObjectDefinitionTuple) -> Bool {
    return lhs.graphDefinitionKey.type == rhs.graphDefinitionKey.type && lhs.graphDefinitionKey.tag == rhs.graphDefinitionKey.tag && lhs.graphDefinition.numberOfArguments == rhs.graphDefinition.numberOfArguments
}

/// Filters a collection of GraphObjectDefinitionTuple returning the ones that
/// can resolve the type of the given GraphDefinitionKey based on tag or type of arguments
///
/// - Parameters:
///   - graphDefinitions: The collection of GraphObjectDefinitionTuple to filter
///   - key: The GraphDefinitionKey they need to resolve
///   - byTag: Filtering by tag or no
///   - byTypeOfArguments: Filtering by the type of arguments or not
/// - Returns: The filtered collection of GraphObjectDefinitionTuple
func filter(graphDefinitions: [GraphObjectDefinitionTuple], key: GraphDefinitionKey, byTag: Bool, byTypeOfArguments: Bool) -> [GraphObjectDefinitionTuple] {
    let result = graphDefinitions.filter({ $0.graphDefinitionKey.type == key.type || $0.graphDefinition.knowsHowToImplement(type: key.type) }).filter({ $0.graphDefinitionKey.tag == key.tag || (!byTag && $0.graphDefinitionKey.tag == nil) })
    
    return byTypeOfArguments ? result.filter({ $0.graphDefinitionKey.typeOfArguments == key.typeOfArguments }) : result
}

/// Returns an ordered collection of GraphObjectDefinitionTuple by the passing tag
///
/// - Parameters:
///   - graphDefinitionsTuples: The collection of GraphObjectDefinitionTuple to order
///   - tag: The tag to use when ordering
/// - Returns: The ordered collection of GraphObjectDefinitionTuple
func sort(graphDefinitionsTuples: [GraphObjectDefinitionTuple], usingTag tag: HelixTag?) -> [GraphObjectDefinitionTuple] {
    return graphDefinitionsTuples.filter({ $0.graphDefinitionKey.tag == tag }) + graphDefinitionsTuples.filter({ $0.graphDefinitionKey.tag != tag })
}
