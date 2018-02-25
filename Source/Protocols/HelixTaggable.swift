//
//  HelixTaggable.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Protocol defining a type to be used as HelixTag
public protocol HelixTaggable {
    var dependencyTag: HelixTag { get }
}

extension String: HelixTaggable {
    public var dependencyTag: HelixTag {
        return .String(self)
    }
}

extension Int: HelixTaggable {
    public var dependencyTag: HelixTag {
        return .Int(self)
    }
}

extension HelixTaggable where Self: RawRepresentable, Self.RawValue == Int {
    public var dependencyTag: HelixTag {
        return .Int(rawValue)
    }
}

extension HelixTaggable where Self: RawRepresentable, Self.RawValue == String {
    public var dependencyTag: HelixTag {
        return .String(rawValue)
    }
}
