//
//  StoryboardInstantiatable.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 25/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import Foundation

public protocol StoryboardInstantiatable: NSObjectProtocol {
    func didInstantiateFromStoryboard(_ helix: Helix, tag: HelixTag?) throws
}

extension StoryboardInstantiatable {
    public func didInstantiateFromStoryboard(_ helix: Helix, tag: HelixTag?) throws {
        try helix.resolve(of: self, tag: tag)
    }
}
