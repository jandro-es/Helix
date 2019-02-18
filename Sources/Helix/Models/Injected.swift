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

/// Protocol definition for auto injected properties
public protocol AutoInjectedProperty: class {
    
    /// The type of the property
    static var type: Any.Type { get }
    
    /// Public resolve method for injecting the property
    ///
    /// - Parameter container: The Helix instance to use
    /// - Throws: Error while resolving
    func resolve(_ helix: Helix) throws
}

public final class Injected<T>: InjectedPropertyType<T>, AutoInjectedProperty {
    
    // MARK: - Public properties
    
    /// The property injected
    public internal(set) var value: T? {
        didSet {
            if let value = value {
                completionHandler(value)
            }
        }
    }
    
    // MARK: - AutoInjectedProperty
    
    /// The type of the injected property
    public static var type: Any.Type {
        return T.self
    }
    
    // MARK: - initializers
    
    init(value: T?, required: Bool, tag: HelixTaggable?, overrideTag: Bool, completionHandler: @escaping (T) -> Void) {
        self.value = value
        super.init(required: required, tag: tag, overrideTag: overrideTag, completionHandler: completionHandler)
    }
    
    // MARK: - Public methods
    
    /// Creates a new Injected object with the same values except the new value
    ///
    /// - Parameter value: The new value
    /// - Returns: An Injected object
    public func setValue(_ value: T?) -> Injected {
        guard (required && value != nil) || required == false else {
            fatalError("If the property is required can't be set to nil")
        }
        return Injected(value: value, required: required, tag: tag, overrideTag: overrideTag, completionHandler: completionHandler)
    }
    
    // MARK: - AutoInjectedProperty
    
    /// Public resolve method for injecting the property
    ///
    /// - Parameter container: The Helix instance to use
    /// - Throws: Error while resolving
    public func resolve(_ helix: Helix) throws {
        let resolved: T? = try super.resolve(with: helix)
        value = resolved
    }
}

/// Weak version of the Injected object, it can only store Reference types
public final class InjectedWeak<T>: InjectedPropertyType<T>, AutoInjectedProperty {
    
    // MARK: - Public properties
    
    /// The property injected
    public var value: T? {
        return valueBoxed?.value
    }
    
    // MARK: - Internal properties
    
    /// The weakly boxed property
    var valueBoxed: WeakBox<T>? = nil {
        didSet {
            if let value = value {
                completionHandler(value)
            }
        }
    }
    
    // MARK: - AutoInjectedProperty
    
    /// The type of the injected property
    public static var type: Any.Type {
        return T.self
    }
    
    // MARK: - Initializer
    
    init(value: T?, required: Bool = true, tag: HelixTaggable?, overrideTag: Bool, completionHandler: @escaping (T) -> Void) {
        self.valueBoxed = value.map(WeakBox.init)
        super.init(required: required, tag: tag, overrideTag: overrideTag, completionHandler: completionHandler)
    }
    
    // MARK: - Public methods
    
    /// Creates a new InjectedWeak object with the same values except the new value
    ///
    /// - Parameter value: The new value
    /// - Returns: An Injected object
    public func setValue(_ value: T?) -> InjectedWeak {
        guard (required && value != nil) || required == false else {
            fatalError("Can not set required property to nil.")
        }
        return InjectedWeak(value: value, required: required, tag: tag, overrideTag: overrideTag, completionHandler: completionHandler)
    }
    
    // MARK: - AutoInjectedProperty
    
    /// Public resolve method for injecting the property
    ///
    /// - Parameter container: The Helix instance to use
    /// - Throws: Error while resolving
    public func resolve(_ helix: Helix) throws {
        let resolved: T? = try super.resolve(with: helix)
        valueBoxed = resolved.map(WeakBox.init)
    }
}

/// Base class for the two concrete implementations
public class InjectedPropertyType<T> {
    
    // MARK: - Internal properties
    
    /// If the property is required or not
    let required: Bool
    
    /// The completion handler to execute after the injection
    let completionHandler: (T) -> Void
    
    /// The tag identifying the property injection
    let tag: HelixTag?
    
    /// Should we override the current tag or not
    let overrideTag: Bool
    
    // MARK: - Initializer
    
    init(required: Bool = true, tag: HelixTaggable?, overrideTag: Bool, completionHandler: @escaping (T) -> Void) {
        self.required = required
        self.tag = tag?.dependencyTag
        self.overrideTag = overrideTag
        self.completionHandler = completionHandler
    }
    
    // MARK: - Internal methods
    
    /// Tries to resolve the auto injected property using the passed Helix object
    ///
    /// - Parameter helix: The Helix to use
    /// - Returns: The resolved type
    /// - Throws: HelixError.propertyInjectionFailed
    func resolve(with helix: Helix) throws -> T? {
        // If we should override the tag we use the passed one, if not we use the one in the context
        let tag = overrideTag ? self.tag : helix.ctx.resolvingTag
        do {
            helix.ctx.key = helix.ctx.key.tagged(with: tag)
            let key = GraphDefinitionKey(type: T.self, typeOfArguments: Void.self, tag: tag?.dependencyTag)
            return try resolve(with: helix, key: key, builder: { (factory: (Any) throws -> Any) in try factory(()) }) as? T
        }
        catch {
            let error = HelixError.propertyInjectionFailed(label: helix.ctx.neededByProperty, type: helix.ctx.typeBeingResolved, underlyingError: error)
            if required {
                throw error
            }
            else {
                debugPrint(error.description)
                return nil
            }
        }
    }
    
    // MARK: - Private methods
    
    /// Tries to resolve the property for the given GraphDefinitionKey and builder using the
    /// given Helix object
    ///
    /// - Parameters:
    ///   - helix: The Helix object to use
    ///   - key: The GraphDefinitionKey
    ///   - builder: The Builder to use
    /// - Returns: Any (Value or Reference types)
    /// - Throws: HelixError.propertyInjectionFailed
    private func resolve<U>(with helix: Helix, key: GraphDefinitionKey, builder: ((U) throws -> Any) throws -> Any) throws -> Any {
        return try helix.resolveDefinition(definitionKey: key, resolvingLambda: { definition throws -> Any in
            try builder(definition.weakFactory)
        })
    }
}
