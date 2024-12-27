public struct FDIContainer: Resolver {
    public static var shared = FDIContainer()
    var factories: [FactoryWrapper] = []

    public mutating func bind<ProtocolType>(_ type: ProtocolType.Type, name: String = "", _ factory: @escaping (Resolver) -> ProtocolType) {
        assert(!factories.contains(where: { $0.supports(type) && $0.name == name }))

        let newFactory = GenericFactory(type, factory: { resolver in
            factory(resolver)
        })
        factories.append(FactoryWrapper(newFactory, name: name))
    }

    public func resolve<ProtocolType>(_ type: ProtocolType.Type) -> ProtocolType {  // Fetch from bucket
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }
    
    public func resolve<ProtocolType>(_ type: ProtocolType.Type, name: String = "") -> ProtocolType { // Fetch from bucket
        guard let factory = factories.first(where: { $0.supports(type) && $0.name == name}) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }
}
