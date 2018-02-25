//
//  NSObject+HelixTag.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 25/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import UIKit

let HelixTagAssociatedObjectKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

extension NSObject {
    
    @objc private(set) public var helixTag: String? {
        get {
            return objc_getAssociatedObject(self, HelixTagAssociatedObjectKey) as? String
        }
        set {
            objc_setAssociatedObject(self, HelixTagAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            guard let instantiatable = self as? StoryboardInstantiatable else {
                return
            }
            let tag = helixTag.map(HelixTag.String)
            for (index, helix) in Helix.ibHelixes.enumerated() {
                do {
                    debugPrint("Trying to resolve an instance of type \(type(of: self)) using the helix at index \(index)")
                    try instantiatable.didInstantiateFromStoryboard(helix, tag: tag)
                    debugPrint("Succesfully resolved instance of type: \(type(of: self))")
                    return
                } catch {}
            }
        }
    }
}
