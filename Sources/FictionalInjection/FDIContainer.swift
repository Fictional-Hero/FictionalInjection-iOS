public class FDIContainer: Resolver {
    public static var shared = FDIContainer()
    var factories: [FactoryWrapper] = []

    public func bind<ProtocolType>(_ type: ProtocolType.Type, scope: FDIScope = .transient, name: String = "", _ factory: @escaping (Resolver) -> ProtocolType) {
        assert(!factories.contains(where: { $0.supports(type) && $0.name == name }))

        let newFactory = GenericFactory(type, scope: scope, factory: { resolver in
            factory(resolver)
        })
        factories.append(FactoryWrapper(newFactory, name: name))
    }

    public func resolve<ProtocolType>(_ type: ProtocolType.Type) -> ProtocolType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }
    
    public func resolve<ProtocolType>(_ type: ProtocolType.Type, name: String = "") -> ProtocolType {
        guard let factory = factories.first(where: { $0.supports(type) && $0.name == name}) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }
}
