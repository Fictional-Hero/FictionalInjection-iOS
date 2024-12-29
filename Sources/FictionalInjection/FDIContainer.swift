import Foundation

public class FDIContainer: Resolver {
    public static var shared = FDIContainer()
    private let lock = NSLock()
    var factories: [FactoryWrapper] = []

    public func bind<ProtocolType>(_ type: ProtocolType.Type, scope: FDIScope = .transient, name: String = "", _ factory: @escaping (Resolver) -> ProtocolType) {
        lock.lock()
        defer { lock.unlock() }
        assert(!self.factories.contains(where: { $0.supports(type) && $0.name == name }))
        
        let newFactory = GenericFactory(type, scope: scope, factory: { resolver in
            factory(resolver)
        })
        self.factories.append(FactoryWrapper(newFactory, name: name))
    }

    public func resolve<ProtocolType>(_ type: ProtocolType.Type) -> ProtocolType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            debugPrint(type: String(describing: type))
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }
    
    public func resolve<ProtocolType>(_ type: ProtocolType.Type, name: String = "") -> ProtocolType {
        guard let factory = factories.first(where: { $0.supports(type) && $0.name == name}) else {
            debugPrint(type: String(describing: type))
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }
    
    public func resolveOptional<ProtocolType>(_ type: ProtocolType.Type) -> ProtocolType? {
        let factory = factories.first(where: { $0.supports(type) })
        if factory == nil {
            debugPrint(type: String(describing: type))
        }
        return factory?.resolve(self)
    }
    
    public func resolveOptional<ProtocolType>(_ type: ProtocolType.Type, name: String = "") -> ProtocolType? {
        let factory = factories.first(where: { $0.supports(type) && $0.name == name})
        if factory == nil {
            debugPrint(type: String(describing: type))
        }
        return factory?.resolve(self)
    }
    
    public func debugPrint(type: String) {
        print("Failed to find binding: \nAvailable bindings ↴ ")
        factories.forEach { factory in
            print("Type: \(type)")
        }
    }
}
