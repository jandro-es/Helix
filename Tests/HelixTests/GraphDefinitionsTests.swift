//
//  GraphDefinitionsTests.swift
//  HelixTests
//
//  Created by Alejandro Barros on 26/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import XCTest
@testable import Helix

private protocol APIServiceType {}
private class APIService: APIServiceType {}

final class GraphDefinitionsTests: XCTestCase {
    
    private typealias F1 = () -> APIService
    private typealias F2 = (String) -> APIService
    let tag1 = HelixTag.String("tag1")
    let tag2 = HelixTag.String("tag2")
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_GraphDefinitionKey_equal() {
        let firstKey = GraphDefinitionKey(type: APIServiceType.self, typeOfArguments: F1.self, tag: tag1)
        let secondKey = GraphDefinitionKey(type: APIServiceType.self, typeOfArguments: F1.self, tag: tag1)
        XCTAssertEqual(firstKey, secondKey)
        XCTAssertEqual(firstKey.hashValue, secondKey.hashValue)
    }
    
    func test_GraphDefinitionKey_nonequal() {
        let firstKey = GraphDefinitionKey(type: APIServiceType.self, typeOfArguments: F1.self, tag: tag1)
        let secondKey = GraphDefinitionKey(type: AnyObject.self, typeOfArguments: F1.self, tag: tag1)
        XCTAssertNotEqual(firstKey, secondKey)
        XCTAssertNotEqual(firstKey.hashValue, secondKey.hashValue)
    }
    
    func test_GraphDefinitionKey_notequal_factory() {
        let firstKey = GraphDefinitionKey(type: APIServiceType.self, typeOfArguments: F1.self, tag: tag1)
        let secondKey = GraphDefinitionKey(type: APIServiceType.self, typeOfArguments: F2.self, tag: tag1)
        XCTAssertNotEqual(firstKey, secondKey)
        XCTAssertNotEqual(firstKey.hashValue, secondKey.hashValue)
    }
    
    func test_GraphDefinitionKey_notequal_tag() {
        let firstKey = GraphDefinitionKey(type: APIServiceType.self, typeOfArguments: F1.self, tag: tag1)
        let secondKey = GraphDefinitionKey(type: APIServiceType.self, typeOfArguments: F1.self, tag: tag2)
        XCTAssertNotEqual(firstKey, secondKey)
        XCTAssertNotEqual(firstKey.hashValue, secondKey.hashValue)
    }
    
    func test_resolve_dependencies_call_block() {
        var blockCalled = false
        let def: GraphDefinition<APIServiceType, ()> = GraphDefinition(creationScope: .unique) { APIService() as APIServiceType }.resolvingProperties { (helix, apiService) in
            blockCalled = true
        }
        try! def.resolveProperties(of: APIService(), helix: Helix(parent: nil, configLambda: nil))
        XCTAssertTrue(blockCalled)
    }
    
    func test_resolve_dependencies_not_call_block_if_wrong_instance() {
        var blockCalled = false
        let def: GraphDefinition<APIServiceType, ()> = GraphDefinition(creationScope: .unique) { APIService() as APIServiceType }.resolvingProperties { (helix, apiService) in
            blockCalled = true
        }
        try! def.resolveProperties(of: String(), helix: Helix(parent: nil, configLambda: nil))
        XCTAssertFalse(blockCalled)
    }
    
    func test_registers_optional_as_forwardtypes() {
        let def: GraphDefinition<APIServiceType, ()> = GraphDefinition(creationScope: .unique) { APIService() as APIServiceType }
        XCTAssertTrue(def.implementingTypes.contains(where: { $0 == APIServiceType?.self }))
        XCTAssertTrue(def.implementingTypes.contains(where: { $0 == APIServiceType?.self }))
    }

    static var allTests = [
        ("test_GraphDefinitionKey_equal", test_GraphDefinitionKey_equal),
        ("test_GraphDefinitionKey_nonequal", test_GraphDefinitionKey_nonequal),
        ("test_GraphDefinitionKey_notequal_factory", test_GraphDefinitionKey_notequal_factory),
        ("test_GraphDefinitionKey_notequal_tag", test_GraphDefinitionKey_notequal_tag),
        ("test_resolve_dependencies_call_block", test_resolve_dependencies_call_block),
        ("test_resolve_dependencies_not_call_block_if_wrong_instance", test_resolve_dependencies_not_call_block_if_wrong_instance),
        ("test_registers_optional_as_forwardtypes", test_registers_optional_as_forwardtypes),
        ]
}
