//
//  HelixTests.swift
//  HelixTests
//
//  Created by Alejandro Barros Cuetos on 24/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import XCTest
@testable import Helix

private protocol APIServiceType: class { }
private class APIService1: APIServiceType { }
private class APIService2: APIServiceType { }

private protocol ServerType: class {
    var client: ClientType! { get }
}
private protocol ClientType: class {
    var server: ServerType! { get }
}

class ResolvableService: APIServiceType, HelixResolvable {
    var didResolveDependenciesCalled = false
    func didResolveDependencies() {
        XCTAssertFalse(didResolveDependenciesCalled, "didResolveDependencies should be called only once per instance")
        didResolveDependenciesCalled = true
    }
}

final class HelixTests: XCTestCase {
    
    let helix = Helix(parent: nil, configLambda: nil)
    
    override func setUp() {
        super.setUp()
        helix.reset()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_helix_does_not_create_retain_cycle() {
        var helix: Helix! = Helix(parent: nil) { helix in
            unowned let helix = helix
            helix.register { APIService1() }
            helix.register { (_: APIService1) -> APIServiceType in
                let _ = helix
                return APIService1() as APIServiceType
                }.resolvingProperties { helix, _ in
                    let _ = helix
            }
        }
        let _ = try! helix.resolve() as APIServiceType
        weak var weakHelix = helix
        helix = nil
        XCTAssertNil(weakHelix)
    }
    
    func test_resolves_instances_without_tag() {
        helix.register { APIService1() as APIServiceType }
        let serviceInstance = try! helix.resolve() as APIServiceType
        XCTAssertTrue(serviceInstance is APIService1)
        let anyService = try! helix.resolve(APIServiceType.self)
        XCTAssertTrue(anyService is APIService1)
        let optService = try! helix.resolve((APIServiceType?).self)
        XCTAssertTrue(optService is APIService1)
        let impService = try! helix.resolve((APIServiceType?).self)
        XCTAssertTrue(impService is APIService1)
    }
}
