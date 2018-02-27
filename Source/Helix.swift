//
//  Helix.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 24/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

public final class Helix {
    
    // MARK: - Internal typealias
    
    typealias SimpleLambda = () throws -> ()
    
    // MARK: - Internal properties
    
    /// A Parent Helix object if present
    let parent: Helix?
    
    /// The Resolving context attached to this Helix object
    var ctx: ResolvingContext!
    
    /// The collection of GraphDefinitions the Helix can resolve
    var graphDefinitions = [GraphDefinitionKey: InternalGraphDefinitionType]()
    
    /// A collection of already resolved items for reuse
    var resolvedItems = ResolvedItems()
    
    /// The Helix object can only be initialized once, this flag will prevent multiple
    /// initializations
    var isInitialized = false
    
    /// A queue of SimpleLambda to execute during initialization
    var initializingQueue: [SimpleLambda] = []
    
    /// A collection of Helix object stored internally as weak references
    /// and returned as unwrapped instances
    var helixes: [Helix] {
        get {
            return weakHelixes.flatMap({ $0.value })
        }
        set {
            weakHelixes = newValue.filter({ $0 !== self }).map(WeakBox.init)
        }
    }
    
    // MARK: - Private properties
    
    /// Mutex for sync in a thread safe way multiple operations
    private let mutex = NSRecursiveLock()
    
    /// Internal weak storage of a collection of Helix instances
    private var weakHelixes: [WeakBox<Helix>] = []
    
    // MARK: - Static properties
    
    static public var ibHelixes: [Helix] = []
    
    // MARK: - Initializers
    
    public init(parent: Helix?, configLambda: ((Helix) -> ())?) {
        self.parent = parent
        configLambda?(self)
    }
    
    // MARK: - Public methods
    
    /// It bootstraps and setup the Helix object
    ///
    /// - Throws: Any error
    public func bootstrap() throws {
        guard !isInitialized else {
            fatalError("An Helix instance can only be bootstraped once")
        }
        try threadLocked {
            isInitialized = true
            try initializingQueue.forEach({ try $0() })
            initializingQueue.removeAll()
        }
    }
    
    /// Adds a series of Helix objects to collaborate in resolving
    /// dependencies
    ///
    /// - Parameter helixes: Variadic collection of Helix objects
    public func collaborate(with helixes: Helix...) {
        self.helixes += helixes
        for helixInstance in helixes {
            helixInstance.helixes += [self]
            helixInstance.resolvedItems.sharedSingletonsBoxed = self.resolvedItems.sharedSingletonsBoxed
            helixInstance.resolvedItems.sharedWeakSingletonsBoxed = self.resolvedItems.sharedWeakSingletonsBoxed
            collaborationReferences(between: helixInstance, and: self)
        }
    }
    
    /// Tries to resolve an instance of type T with the given tag
    ///
    /// - Parameter tag: The tag
    /// - Returns: The instance of the type if succeeded
    /// - Throws: Possible errors during resolution
    public func resolve<T>(tag: HelixTaggable? = nil) throws -> T {
        return try resolve(tag: tag, resolvingLambda: { (factory: () throws -> T) in
            try factory()
        })
    }
    
    /// Tries to resolve and instance of type T with the given tag
    /// without being strictily typed
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag
    /// - Returns: The resolved instance
    /// - Throws: Possible errors during resolution
    public func resolve(_ type: Any.Type, tag: HelixTaggable? = nil) throws -> Any {
        return try resolve(type, tag: tag) { (factory: () throws -> Any) in
            try factory()
        }
    }
    
    /// Tries to resolve and instance of the inferred type T with one argument
    ///
    /// - Parameters:
    ///   - tag: The tag of the definition
    ///   - arg1: One argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<T, A>(tag: HelixTaggable? = nil, arguments arg1: A) throws -> T {
        return try resolve(tag: tag) { factory in
            try factory(arg1)
        }
    }
    
    /// Tries to resolve and instance of the given type with one argument
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag of the definition
    ///   - arg1: One argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<A>(_ type: Any.Type, tag: HelixTaggable? = nil, arguments arg1: A) throws -> Any {
        return try resolve(type, tag: tag) { factory in
            try factory(arg1)
        }
    }
    
    /// Tries to resolve and instance of the inferred type T with two arguments
    ///
    /// - Parameters:
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<T, A, B>(tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B) throws -> T {
        return try resolve(T.self, tag: tag) { factory in
            try factory((arg1, arg2))
            } as! T
    }
    
    /// Tries to resolve and instance of the given type with two arguments
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<A, B>(_ type: Any.Type, tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B) throws -> Any {
        return try resolve(type, tag: tag) { factory in
            try factory((arg1, arg2))
        }
    }
    
    /// Tries to resolve and instance of the inferred type T with three arguments
    ///
    /// - Parameters:
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    ///   - arg3: Third argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<T, A, B, C>(tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B, _ arg3: C) throws -> T {
        return try resolve(T.self, tag: tag) { factory in
            try factory((arg1, arg2, arg3))
            } as! T
    }
    
    /// Tries to resolve and instance of the given type with three arguments
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    ///   - arg3: Third argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<A, B, C>(_ type: Any.Type, tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B, _ arg3: C) throws -> Any {
        return try resolve(type, tag: tag) { factory in
            try factory((arg1, arg2, arg3))
        }
    }
    
    /// Tries to resolve and instance of the inferred type T with four arguments
    ///
    /// - Parameters:
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    ///   - arg3: Third argument
    ///   - arg4: Fourth argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<T, A, B, C, D>(tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) throws -> T {
        return try resolve(T.self, tag: tag) { factory in
            try factory((arg1, arg2, arg3, arg4))
            } as! T
    }
    
    /// Tries to resolve and instance of the given type with four arguments
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    ///   - arg3: Third argument
    ///   - arg4: Fourth argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<A, B, C, D>(_ type: Any.Type, tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) throws -> Any {
        return try resolve(type, tag: tag) { factory in
            try factory((arg1, arg2, arg3, arg4))
        }
    }
    
    /// Tries to resolve and instance of the inferred type T with five arguments
    ///
    /// - Parameters:
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    ///   - arg3: Third argument
    ///   - arg4: Fourth argument
    ///   - arg5: Fifth argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<T, A, B, C, D, E>(tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) throws -> T {
        return try resolve(T.self, tag: tag) { factory in
            try factory((arg1, arg2, arg3, arg4, arg5))
            } as! T
    }
    
    /// Tries to resolve and instance of the given type with five arguments
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag of the definition
    ///   - arg1: First argument
    ///   - arg2: Second argument
    ///   - arg3: Third argument
    ///   - arg4: Fourth argument
    ///   - arg5: Fifth argument
    /// - Returns: The resolved type
    /// - Throws: Any error during resolution
    public func resolve<A, B, C, D, E>(_ type: Any.Type, tag: HelixTaggable? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) throws -> Any {
        return try resolve(type, tag: tag) { factory in
            try factory((arg1, arg2, arg3, arg4, arg5))
        }
    }
    
    /// Tries to resolve UI instances when used with storyboards
    ///
    /// - Parameters:
    ///   - instance: Instance of the type to resolve
    ///   - tag: Tag associated with it
    /// - Throws: Errors while resolving
    public func resolve<T>(of instance: T, tag: HelixTag? = nil) throws {
        _ = try resolve(tag: tag) { (_: () throws -> T) in
            instance
        }
    }
    
    /// Adds a GraphDefinition for the specified type to the instance of Helix
    ///
    /// - Parameters:
    ///   - graphDefinition: The Graphdefinition to add
    ///   - type: The type which the GraphDefinition will resolve
    ///   - tag: The tag for the definition
    /// - Returns: The added definition
    @discardableResult public func add<T, U, F>(graphDefinition: GraphDefinition<T, U>, type: F.Type, tag: HelixTaggable? = nil) -> GraphDefinition<F, U> {
        guard graphDefinition.helix === self else {
            fatalError("The Helix instance of the GrapDefinition needs to be the same")
        }
        let key = GraphDefinitionKey(type: F.self, typeOfArguments: U.self, tag: nil)
        let forwardDefinition = GraphDefinitionBuilder<F, U> { (definition) in
            definition.creationScope = graphDefinition.creationScope
            let factory = graphDefinition.factory
            definition.factory = { [unowned self] in
                let resolved = try factory($0)
                if let resolved = resolved as? F {
                    return resolved
                }
                else {
                    throw HelixError.invalidType(resolved: resolved, key: key.tagged(with: self.ctx.resolvingTag))
                }
            }
            definition.numberOfArguments = graphDefinition.numberOfArguments
            definition.wiringFactory = graphDefinition.autoWiringFactory.map({ factory in
                { [unowned self] in
                    let resolved = try factory($0, $1)
                    if let resolved = resolved as? F {
                        return resolved
                    }
                    else {
                        throw HelixError.invalidType(resolved: resolved, key: key.tagged(with: self.ctx.resolvingTag))
                    }
                }
            })
            definition.resolvesWith = graphDefinition
            }.build()
        add(graphDefinition: forwardDefinition, tag: tag)
        return forwardDefinition
    }
    
    /// Adds a GraphDefinition for the resolved type to the instance of Helix
    ///
    /// - Parameters:
    ///   - graphDefinition: The Graphdefinition to add
    ///   - tag: The tag for the definition
    public func add<T, U>(graphDefinition: GraphDefinition<T, U>, tag: HelixTaggable? = nil) {
        addDefinition(graphDefinition, tag: tag)
    }
    
    /// Adds to the Helix instance a building factory for the type T with the given tag
    ///
    /// - Parameters:
    ///   - scope: The scope the type, shared by default
    ///   - type: The type which will resolve
    ///   - tag: The tag to associate it with
    ///   - factory: The resolving factory
    /// - Returns: The GraphDefinition
    @discardableResult public func register<T>(_ scope: CreationScope = .shared, type: T.Type = T.self, tag: HelixTaggable? = nil, factory: @escaping (()) throws -> T) -> GraphDefinition<T, ()> {
        let graphDefinition = GraphDefinitionBuilder<T, ()> {
            $0.creationScope = scope
            $0.factory = factory
            }.build()
        add(graphDefinition: graphDefinition, tag: tag)
        return graphDefinition
    }
    
    /// Adds a factory with one parameter to the Helix container
    ///
    /// - Parameters:
    ///   - scope: The creation scope for the type, shared by default
    ///   - type: The type wich will resolve
    ///   - tag: The tag to associate it with
    ///   - factory: The resolving factory
    /// - Returns: The GraphDefinition
    @discardableResult public func register<T, A>(_ scope: CreationScope = .shared, type: T.Type = T.self, tag: HelixTaggable? = nil, factory: @escaping ((A)) throws -> T) -> GraphDefinition<T, A> {
        return register(scope: scope, type: type, tag: tag, factory: factory, numberOfArguments: 1) { container, tag in try factory(container.resolve(tag: tag)) }
    }
    
    /// Adds a factory with two parameters to the Helix container
    ///
    /// - Parameters:
    ///   - scope: The creation scope for the type, shared by default
    ///   - type: The type wich will resolve
    ///   - tag: The tag to associate it with
    ///   - factory: The resolving factory
    /// - Returns: The GraphDefinition
    @discardableResult public func register<T, A, B>(_ scope: CreationScope = .shared, type: T.Type = T.self, tag: HelixTaggable? = nil, factory: @escaping ((A, B)
        ) throws -> T) -> GraphDefinition<T, (A, B)> {
        return register(scope: scope, type: type, tag: tag, factory: factory, numberOfArguments: 2) { container, tag in try factory((container.resolve(tag: tag), container.resolve(tag: tag))) }
    }
    
    /// Adds a factory with three parameters to the Helix container
    ///
    /// - Parameters:
    ///   - scope: The creation scope for the type, shared by default
    ///   - type: The type wich will resolve
    ///   - tag: The tag to associate it with
    ///   - factory: The resolving factory
    /// - Returns: The GraphDefinition
    @discardableResult public func register<T, A, B, C>(_ scope: CreationScope = .shared, type: T.Type = T.self, tag: HelixTaggable? = nil, factory: @escaping ((A, B, C)) throws -> T) -> GraphDefinition<T, (A, B, C)> {
        return register(scope: scope, type: type, tag: tag, factory: factory, numberOfArguments: 3)  { container, tag in try factory((container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag))) }
    }
    
    /// Adds a factory with four parameters to the Helix container
    ///
    /// - Parameters:
    ///   - scope: The creation scope for the type, shared by default
    ///   - type: The type wich will resolve
    ///   - tag: The tag to associate it with
    ///   - factory: The resolving factory
    /// - Returns: The GraphDefinition
    @discardableResult public func register<T, A, B, C, D>(_ scope: CreationScope = .shared, type: T.Type = T.self, tag: HelixTaggable? = nil, factory: @escaping ((A, B, C, D)) throws -> T) -> GraphDefinition<T, (A, B, C, D)> {
        return register(scope: scope, type: type, tag: tag, factory: factory, numberOfArguments: 4) { container, tag in try factory((container.resolve(tag: tag),  container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag))) }
    }
    
    /// Adds a factory with five parameters to the Helix container
    ///
    /// - Parameters:
    ///   - scope: The creation scope for the type, shared by default
    ///   - type: The type wich will resolve
    ///   - tag: The tag to associate it with
    ///   - factory: The resolving factory
    /// - Returns: The GraphDefinition
    @discardableResult public func register<T, A, B, C, D, E>(_ scope: CreationScope = .shared, type: T.Type = T.self, tag: HelixTaggable? = nil, factory: @escaping ((A, B, C, D, E)) throws -> T) -> GraphDefinition<T, (A, B, C, D, E)> {
        return register(scope: scope, type: type, tag: tag, factory: factory, numberOfArguments: 5) { container, tag in try factory((container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag))) }
    }
    
    /// Registers a storyboard of type T associated with the given tag
    ///
    /// - Parameters:
    ///   - type: The type of the storyboard
    ///   - tag: The tag to associate it with
    /// - Returns: Returns a GraphDefinition
    public func register<T: NSObject>(storyboardType type: T.Type, tag: HelixTaggable? = nil) -> GraphDefinition<T, ()> where T: StoryboardInstantiatable {
        return register(.shared, type: type, tag: tag, factory: { T() })
    }
    
    /// Tries to validate the whole configuration of the Helix instance by resolving every
    /// definition using the values passed
    ///
    /// - Parameter _arguments: The values to use for the validation
    /// - Throws: Any possible error while resolving
    public func validate(with args: Any...) throws {
        validateNextDefinition: for (key, _) in graphDefinitions {
            do {
                for arg in args {
                    guard type(of: arg) == key.typeOfArguments else {
                        continue
                    }
                    do {
                        let _ = try resolveWithContext(definitionKey:key, neededByType: nil, resolvesInCollaboration: false, helix: self) {
                            try self.resolveDefinition(definitionKey: key, resolvingLambda: { definition throws -> Any in
                                try definition.weakFactory(arg)
                            })
                        }
                        continue validateNextDefinition
                    }
                    catch let error as HelixError {
                        throw error
                    }
                    catch {
                        debugPrint("Ignoring this error: \(error)")
                    }
                    do {
                        let _ = try self.resolve(key.type, tag: key.tag)
                    }
                    catch let error as HelixError {
                        throw error
                    }
                    catch {
                        debugPrint("Ignoring this error: \(error)")
                    }
                }
            }
        }
    }
    
    /// Removes a GraphDefinition from the Helix' instance
    ///
    /// - Parameters:
    ///   - graphDefinition: The GraphDefinition to remove
    ///   - tag: The tag of the definition
    public func remove<T, U>(graphDefinition: GraphDefinition<T, U>, tag: HelixTaggable? = nil) {
        guard !isInitialized else {
            fatalError("Impossible to remove a definition once the instance has been bootstraped")
        }
        let key = GraphDefinitionKey(type: T.self, typeOfArguments: U.self, tag: tag?.dependencyTag)
        threadLocked {
            graphDefinitions[key]?.helix = nil
            graphDefinitions[key] = nil
            resolvedItems.singletons[key] = nil
            resolvedItems.weakSingletons[key] = nil
            resolvedItems.sharedSingletons[key] = nil
            resolvedItems.sharedWeakSingletons[key] = nil
        }
    }
    
    /// Resets the Helix instance
    public func reset() {
        threadLocked {
            graphDefinitions.forEach { $0.1.helix = nil }
            graphDefinitions.removeAll()
            resolvedItems.singletons.removeAll()
            resolvedItems.weakSingletons.removeAll()
            resolvedItems.sharedSingletons.removeAll()
            resolvedItems.sharedWeakSingletons.removeAll()
            isInitialized = false
        }
    }
    
    // MARK: - Internal methods
    
    /// Executes the passed Lambda in thread safe way
    /// using a common mutex for the instance
    ///
    /// - Parameter lambda: The lambda to execute
    /// - Returns: The lambda return value
    /// - Throws: Possible errors throw by the lambda
    func threadLocked<T>(_ lambda: () throws -> T) rethrows -> T {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        return try lambda()
    }
    
    /// Tries to resolve the dependency using a context with the given parameters
    ///
    /// - Parameters:
    ///   - key: The GraphDefinitionKey to resolve
    ///   - neededByType: The type that needs the dependency if that's the case
    ///   - neededByProperty: The property that needs the dependency if that's the case
    ///   - resolvesInCollaboration: The resolving happens in collaboration
    ///   - helix: The Helix instance
    ///   - lambda: The lambda function to use
    /// - Returns: The resolved type
    /// - Throws: Possible errors during resolving
    func resolveWithContext<T>(definitionKey: GraphDefinitionKey, neededByType: Any.Type?, neededByProperty: String? = nil, resolvesInCollaboration: Bool, helix: Helix, lambda: () throws -> T) rethrows -> T {
        return try threadLocked {
            let savedContext = self.ctx
            defer {
                ctx = savedContext
                if ctx == nil {
                    resolvedItems.resolvedItems.removeAll()
                    for (key, instance) in resolvedItems.sharedWeakSingletons {
                        // We make sure that the shared resolved items are stored as weak references
                        if resolvedItems.sharedWeakSingletons[key] is WeakBoxType {
                            continue
                        }
                        resolvedItems.sharedWeakSingletons[key] = WeakBox(instance)
                    }
                    for (key, instance) in resolvedItems.weakSingletons {
                        // We make sure that the non shared resolved items are stored as weak references
                        if resolvedItems.weakSingletons[key] is WeakBoxType {
                            continue
                        }
                        resolvedItems.weakSingletons[key] = WeakBox(instance)
                    }
                    for resolvedInstance in resolvedItems.resolvableItems.reversed() {
                        resolvedInstance.didResolveDependencies()
                    }
                    resolvedItems.resolvableItems.removeAll()
                }
            }
            ctx = ResolvingContext(key: definitionKey, neededByType: neededByType, neededByProperty: neededByProperty, isCollaborating: resolvesInCollaboration, helix: helix)
            do {
                return try lambda()
            }
            catch {
                debugPrint(error)
                throw error
            }
        }
    }
    
    /// Tries to resolve an instance of type T using a resolving Lambda
    ///
    /// - Parameters:
    ///   - tag: The tag for the resolution
    ///   - resolvingLambda: The lambda used to resolve
    /// - Returns: An instance of type T if succeeded
    /// - Throws: Any error during resolution
    func resolve<T, U>(tag: HelixTaggable? = nil, resolvingLambda: ((U) throws -> T) throws -> T) throws -> T {
        return try resolve(T.self, tag: tag, resolvingLambda: { factory in
            try withoutActuallyEscaping(factory, do: { (factory) throws -> T in
                try resolvingLambda({ try factory($0) as! T })
            })
        }) as! T
    }
    
    /// Tries to resolve an instance of type T using a resolving Lambda without parameters
    ///
    /// - Parameters:
    ///   - tag: The tag for the resolution
    ///   - resolvingLambda: The lambda used to resolve
    /// - Returns: An instance of type T if succeeded
    /// - Throws: Any error during resolution
    func resolve<T>(tag: HelixTaggable? = nil, resolvingLambda: (() throws -> T) throws -> T) throws -> T {
        return try resolve(T.self, tag: tag, resolvingLambda: { factory in
            try withoutActuallyEscaping(factory, do: { (factory) throws -> T in
                try resolvingLambda({ try factory() as! T })
            })
        }) as! T
    }
    
    /// Tries to resolve a weak instance of type T using a resolving Lambda
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag for the resolution
    ///   - resolvingLambda: The lambda used to resolve
    /// - Returns: An instance of type T if succeeded
    /// - Throws: Any error during resolution
    func resolve<U>(_ type: Any.Type, tag: HelixTaggable? = nil, resolvingLambda: ((U) throws -> Any) throws -> Any) throws -> Any {
        let key = GraphDefinitionKey(type: type, typeOfArguments: U.self, tag: tag?.dependencyTag)
        return try resolveWithContext(definitionKey:key, neededByType: ctx?.typeBeingResolved, resolvesInCollaboration: false, helix: self) {
            try self.resolveDefinition(definitionKey: key, resolvingLambda: { definition in
                try resolvingLambda(definition.weakFactory)
            })
        }
    }
    
    /// Tries to resolve a weak instance of type T using a resolving Lambda without parameters
    ///
    /// - Parameters:
    ///   - type: The type to resolve
    ///   - tag: The tag for the resolution
    ///   - resolvingLambda: The lambda used to resolve
    /// - Returns: An instance of type T if succeeded
    /// - Throws: Any error during resolution
    func resolve(_ type: Any.Type, tag: HelixTaggable? = nil, resolvingLambda: (() throws -> Any) throws -> Any) throws -> Any {
        let key = GraphDefinitionKey(type: type, typeOfArguments: Void.self, tag: tag?.dependencyTag)
        return try resolveWithContext(definitionKey:key, neededByType: ctx?.typeBeingResolved, resolvesInCollaboration: false, helix: self) {
            try self.resolveDefinition(definitionKey: key, resolvingLambda: { definition in
                try resolvingLambda { try definition.weakFactory(()) }
            })
        }
    }
    
    /// Searchs the definition graph for the given definition key and tries to resolve
    /// an instance of type T
    ///
    /// - Parameters:
    ///   - definitionKey: The key of the GraphDefinition
    ///   - resolvingLambda: The lambda to execute for resolution
    /// - Returns: An instance of type T if succeeded
    /// - Throws: Any possible error while resolving
    func resolveDefinition<T>(definitionKey: GraphDefinitionKey, resolvingLambda: (InternalGraphDefinitionType) throws -> T) throws -> T {
        guard let matchedDefinition = self.matching(definitionKey: definitionKey) else {
            do {
                return try autowiring(definitionKey: definitionKey)
            } catch {
                if let resolved = resolveWithCollaboratingHelixes(graphDefinitionKey: definitionKey, graphBuilder: resolvingLambda) {
                    return resolved
                }
                if let resolved = parentResolve(definitionKey: definitionKey, resolvingLambda: resolvingLambda) {
                    return resolved
                }
                throw error
            }
        }
        let (key, definition) = matchedDefinition
        if let previouslyResolved: T = alreadyResolved(graphDefinition: definition, key: key) {
            debugPrint("The instance is already resolved, reusing it \(previouslyResolved)")
            return previouslyResolved
        }
        var resolvedInstance = try resolvingLambda(definition)
        // Type erasure
        if let box = resolvedInstance as? BoxType, let unboxed = box.unboxed as? T {
            resolvedInstance = unboxed
        }
        if let previouslyResolved: T = alreadyResolved(graphDefinition: definition, key: key) {
            debugPrint("The instance is already resolved after type erasure matching, reusing it \(previouslyResolved)")
            return previouslyResolved
        }
        resolvedItems[key: key, for: definition.creationScope, ctx.isCollaborating] = resolvedInstance
        if let resolvable = resolvedInstance as? HelixResolvable {
            resolvedItems.resolvableItems.append(resolvable)
            resolvable.resolveDependencies(with: self)
        }
        try autoInjectProperties(in: resolvedInstance)
        try definition.resolveProperties(of: resolvedInstance, helix: self)
        debugPrint("Can not reuse, new instance resolved for \(key.type) with \(resolvedInstance)")
        return resolvedInstance
    }
    
    /// Searches for already resolved instances for the give GraphDefinition and GraphDefinitionKey, if
    /// an exact match is found it returns it, if not gets all the related ones and tries to cast it,
    /// returning it if possible
    ///
    /// - Parameters:
    ///   - graphDefinition: The graphDefinition of the instance to resolve
    ///   - key: The graphDefinitionKey if the instance to resolve
    /// - Returns: The already resolved instance if found
    func alreadyResolved<T>(graphDefinition: InternalGraphDefinitionType, key: GraphDefinitionKey) -> T? {
        if let previouslyResolved = resolvedItems[key: key, for: graphDefinition.creationScope, ctx.isCollaborating] as? T {
            return previouslyResolved
        }
        let keys = graphDefinition.implementingTypes.map({
            GraphDefinitionKey(type: $0, typeOfArguments: key.typeOfArguments, tag: key.tag)
        })
        for key in keys {
            if let previouslyResolved = resolvedItems[key: key, for: graphDefinition.creationScope, ctx.isCollaborating] as? T {
                return previouslyResolved
            }
        }
        return nil
    }
    
    /// Searches for a graphDefinition that matches the given graphDefinitionKey
    ///
    /// - Parameter definitionKey: The graphDefinitionKey to match
    /// - Returns: The matching GraphObjectDefinitionTuple if found
    func matching(definitionKey: GraphDefinitionKey) -> GraphObjectDefinitionTuple? {
        if let definition = (self.graphDefinitions[definitionKey] ?? self.graphDefinitions[definitionKey.tagged(with: nil)]) {
            return (definitionKey, definition)
        }
        if graphDefinitions.filter({ $0.0.type == definitionKey.type }).isEmpty {
            return typeForwardingDefinition(definitionKey: definitionKey)
        }
        return nil
    }
    
    /// Tries to resolve searching through the parent
    ///
    /// - Parameters:
    ///   - definitionKey: The graphDefinitionKey of the dependency
    ///   - resolvingLambda: The lambda to execute for the resolution
    /// - Returns: An instance of type T if possible
    func parentResolve<T>(definitionKey: GraphDefinitionKey, resolvingLambda: (InternalGraphDefinitionType) throws -> T) -> T? {
        guard let parent = self.parent else {
            return nil
        }
        let resolved = try? parent.resolveWithContext(definitionKey: definitionKey, neededByType: ctx.neededByType, neededByProperty: ctx.neededByProperty, resolvesInCollaboration: ctx.isCollaborating, helix: ctx.helix, lambda: { () throws -> T in
            let cachedResolvedItems = parent.resolvedItems.resolvedItems
            parent.resolvedItems.resolvedItems = self.ctx.helix.resolvedItems.resolvedItems
            defer {
                parent.resolvedItems.resolvedItems = cachedResolvedItems
            }
            do {
                let resolved = try parent.resolveDefinition(definitionKey: definitionKey, resolvingLambda: resolvingLambda)
                parent.resolvedItems.resolvedItems.forEach({ (key: GraphDefinitionKey, value: Any) in
                    self.ctx.helix.resolvedItems.resolvedItems[key] = value
                })
                return resolved
            } catch {
                throw error
            }
        })
        return resolved
    }

    /// Looks for a definition that forwards the same type
    ///
    /// - Parameter definitionKey: The definitionKey
    /// - Returns: The definition tuple if found
    func typeForwardingDefinition(definitionKey: GraphDefinitionKey) -> GraphObjectDefinitionTuple? {
        var forwardingDefinitions = graphDefinitions.map({ GraphObjectDefinitionTuple(graphDefinitionKey: $0.0, graphDefinition: $0.1) })
        forwardingDefinitions = filter(graphDefinitions: forwardingDefinitions, key: definitionKey, byTag: false, byTypeOfArguments: true)
        forwardingDefinitions = sort(graphDefinitionsTuples: forwardingDefinitions, usingTag: definitionKey.tag)
        return forwardingDefinitions.first
    }
    
    /// Updates the references of the given Helix object to match
    /// the ones of the given collaborator
    ///
    /// - Parameters:
    ///   - helix: The Helix object
    ///   - collaborator: The Helix object collaborating
    func collaborationReferences(between helix: Helix, and collaborator: Helix) {
        for subHelix in helix.helixes {
            guard subHelix.resolvedItems.sharedSingletonsBoxed !== collaborator.resolvedItems.sharedSingletonsBoxed else {
                continue
            }
            subHelix.resolvedItems.sharedSingletonsBoxed = collaborator.resolvedItems.sharedSingletonsBoxed
            subHelix.resolvedItems.sharedWeakSingletonsBoxed = collaborator.resolvedItems.sharedWeakSingletonsBoxed
            collaborationReferences(between: subHelix, and: collaborator)
        }
    }
    
    /// Tries to resolve the graph object using this instance collaborating Helixes
    ///
    /// - Parameters:
    ///   - graphDefinitionKey: The graph key to resolve
    ///   - graphBuilder: The builder to use
    /// - Returns: The resolved type if possible
    func resolveWithCollaboratingHelixes<T>(graphDefinitionKey: GraphDefinitionKey, graphBuilder: (InternalGraphDefinitionType) throws -> T) -> T? {
        for helix in helixes {
            guard let ctx = helix.ctx, ctx.typeBeingResolved == graphDefinitionKey.type && ctx.resolvingTag == graphDefinitionKey.tag else {
                continue
            }
            do {
                let cachedResolvedItems = helix.resolvedItems
                helix.resolvedItems = self.resolvedItems
                let cachedContext = helix.ctx
                helix.ctx = self.ctx
                defer {
                    helix.ctx = cachedContext
                    helix.resolvedItems = cachedResolvedItems
                    for (definitionKey, resolvedSingleton) in self.resolvedItems.singletons {
                        helix.resolvedItems.singletons[definitionKey] = resolvedSingleton
                    }
                    for (_, resolvedSingleton) in self.resolvedItems.weakSingletons {
                        guard helix.matching(definitionKey: graphDefinitionKey) != nil else {
                            continue
                        }
                        helix.resolvedItems.weakSingletons[graphDefinitionKey] = WeakBox(resolvedSingleton)
                    }
                    for (_, resolved) in self.resolvedItems.resolvedItems {
                        guard helix.matching(definitionKey: graphDefinitionKey) != nil else {
                            continue
                        }
                        helix.resolvedItems.resolvedItems[graphDefinitionKey] = resolved
                    }
                }
                let resolved = try helix.resolveWithContext(definitionKey: graphDefinitionKey, neededByType: self.ctx.neededByType, neededByProperty: self.ctx.neededByProperty, resolvesInCollaboration: true, helix: self.ctx.helix) {
                    try helix.resolveDefinition(definitionKey: graphDefinitionKey, resolvingLambda: graphBuilder)
                }
                return resolved
            }
            catch let error {
                debugPrint("Ignoring error: \(error)")
            }
        }
        return nil
    }
    
    /// Adds a definition for the inferred type with the given tag
    ///
    /// - Parameters:
    ///   - definitionKey: The GraphDefinition to add
    ///   - tag: The tag to match with the GraphDefinition
    func addDefinition<T, U>(_ graphDefinition: GraphDefinition<T, U>, tag: HelixTaggable? = nil) {
        guard !isInitialized else {
            fatalError("Impossible to add a definition once the instance has been bootstraped")
        }
        let definition = graphDefinition
        threadLocked {
            let key = GraphDefinitionKey(type: T.self, typeOfArguments: U.self, tag: tag?.dependencyTag)
            if let _ = graphDefinitions[key] {
                remove(graphDefinition: definition)
            }
            definition.helix = self
            graphDefinitions[key] = definition
            resolvedItems.singletons[key] = nil
            resolvedItems.weakSingletons[key] = nil
            resolvedItems.sharedSingletons[key] = nil
            resolvedItems.sharedWeakSingletons[key] = nil
            if .singleton == definition.creationScope {
                initializingQueue.append({ _ = try self.resolve(tag: tag) as T })
            }
        }
    }
    
    /// Adds to the Helix instance a generic building factory with the given tag
    ///
    /// - Parameters:
    ///   - scope: The scope the type
    ///   - type: The type which will resolve
    ///   - tag: The tag to associate it with
    ///   - factory: The resolving factory lambda
    ///   - numberOfArguments: The number of arguments the type needs
    ///   - autoWiringFactory: The autowiring factory if needed
    /// - Returns: The GraphDefinition
    func register<T, U>(scope: CreationScope, type: T.Type, tag: HelixTaggable?, factory: @escaping (U) throws -> T, numberOfArguments: Int, autoWiringFactory: @escaping (Helix, HelixTag?) throws -> T) -> GraphDefinition<T, U> {
        let graphDefinition = GraphDefinitionBuilder<T, U> {
            $0.creationScope = scope
            $0.factory = factory
            $0.numberOfArguments = numberOfArguments
            $0.wiringFactory = autoWiringFactory
            }.build()
        add(graphDefinition: graphDefinition, tag: tag)
        return graphDefinition
    }
    
    /// Tries to resolve the properties for the given instance
    ///
    /// - Parameter instance: The instance to resolve it's properties
    /// - Throws: Possible errors while resolving
    func autoInjectProperties(in instance: Any) throws {
        let mirror = Mirror(reflecting: instance)
        var superClassMirror = mirror.superclassMirror
        while superClassMirror != nil {
            try superClassMirror?.children.forEach(resolveProperties)
            superClassMirror = superClassMirror?.superclassMirror
        }
        try mirror.children.forEach(resolveProperties)
    }
    
    /// Tries to resolve the properties marked as inject
    ///
    /// - Parameter child: The instance
    /// - Throws: Any possible error while resolving
    func resolveProperties(child: Mirror.Child) throws {
        guard !String(describing: type(of: child.value)).hasPrefix("ImplicitlyUnwrappedOptional") else {
            return
        }
        guard let injectedPropertyBox = child.value as? AutoInjectedProperty else {
            return
        }
        let wrappedType = type(of: injectedPropertyBox).type
        let contextKey = GraphDefinitionKey(type: wrappedType, typeOfArguments: Void.self, tag: ctx.resolvingTag)
        try resolveWithContext(definitionKey:contextKey, neededByType: ctx?.typeBeingResolved, neededByProperty: child.label, resolvesInCollaboration: false, helix: self.ctx.helix) {
            try injectedPropertyBox.resolve(ctx.helix)
        }
    }
    
    /// Tries to resolve an instance using Auto Wiring
    ///
    /// - Parameter definitionKey: The definitionKey of the dependency
    /// - Returns: The resolved instance
    /// - Throws: Any error while resolving
    func autowiring<T>(definitionKey: GraphDefinitionKey) throws -> T {
        guard definitionKey.typeOfArguments == Void.self else {
            throw HelixError.graphDefinitionNotFound(key: definitionKey)
        }
        let autoWiringKey = try autoWiringDefinition(definitionKey: definitionKey).graphDefinitionKey
        do {
            let key = autoWiringKey.tagged(with: definitionKey.tag ?? ctx.resolvingTag)
            return try resolveDefinition(definitionKey: key) { definition in
                try definition.autoWiringFactory!(self.ctx.helix, key.tag) as! T
            }
        }
        catch {
            throw HelixError.autoWiringFailed(type: definitionKey.type, underlyingError: error)
        }
    }
    
    /// Tries to find a GraphObjectDefinitionTuple from the GraphDefinitionKey depending if the
    /// tag exists or not
    ///
    /// - Parameter definitionKey: The definitionKey to search for
    /// - Returns: The tuple
    /// - Throws: Any error during search
    func autoWiringDefinition(definitionKey: GraphDefinitionKey) throws -> GraphObjectDefinitionTuple {
        do {
            return try autoWiringDefinition(definitionKey: definitionKey, strictByTag: true)
        } catch  {
            if definitionKey.tag != nil {
                return try autoWiringDefinition(definitionKey: definitionKey, strictByTag: false)
            } else {
                throw error
            }
        }
    }
    
    /// Tries to find a GraphObjectDefinitionTuple from the GraphDefinitionKey depending if the
    /// tag exists or not
    ///
    /// - Parameters:
    /// - Parameter definitionKey: The definitionKey to search for
    ///   - strictByTag: If the search should be tag strict or not
    /// - Returns: The tuple
    /// - Throws: Any error during search
    private func autoWiringDefinition(definitionKey: GraphDefinitionKey, strictByTag: Bool) throws -> GraphObjectDefinitionTuple {
        var definitions = self.graphDefinitions.map({ GraphObjectDefinitionTuple(graphDefinitionKey: $0.0, graphDefinition: $0.1) })
        definitions = filter(graphDefinitions: definitions, key: definitionKey, byTag: strictByTag, byTypeOfArguments: false)
        definitions = definitions.sorted(by: { $0.graphDefinition.numberOfArguments > $1.graphDefinition.numberOfArguments })
        guard definitions.count > 0 && definitions[0].graphDefinition.numberOfArguments > 0 else {
            throw HelixError.graphDefinitionNotFound(key: definitionKey)
        }
        let maximumNumberOfArguments = definitions.first?.graphDefinition.numberOfArguments
        definitions = definitions.filter({ $0.graphDefinition.numberOfArguments == maximumNumberOfArguments })
        if definitions.count > 1 && definitions[0].graphDefinitionKey.typeOfArguments != definitions[1].graphDefinitionKey.typeOfArguments {
            let error = HelixError.conflictGraphDefinition(type: definitionKey.type, definitions: definitions.map({ $0.graphDefinition }))
            throw HelixError.autoWiringFailed(type: definitionKey.type, underlyingError: error)
        } else {
            return definitions[0]
        }
    }
}

// MARK: - CustomStringConvertible

extension Helix: CustomStringConvertible {
    
    public var description: String {
        return "Helix instance with definitions: \(graphDefinitions.count)\n" + graphDefinitions.map({ "\($0.0)" }).joined(separator: "\n")
    }
    
}
