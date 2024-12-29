protocol ServiceFactory {
    associatedtype ProtocolType
    func resolve(_ resolver: Resolver) -> ProtocolType
}

final class FactoryWrapper {
    private let resolve: (Resolver) -> Any
    private let supports: (Any.Type) -> Bool
    let name: String

    init<T: ServiceFactory>(_ serviceFactory: T, name: String) {
        self.name = name
        self.resolve = { resolver -> Any in
            serviceFactory.resolve(resolver)
        }
        self.supports = { $0 == T.ProtocolType.self }
    }

    func resolve<ProtocolType>(_ resolver: Resolver) -> ProtocolType {
        return resolve(resolver) as! ProtocolType
    }

    func supports<ProtocolType>(_ type: ProtocolType.Type) -> Bool {
        return supports(type)
    }
}


class GenericFactory<ProtocolType>: ServiceFactory {
    private let factory: (Resolver) -> ProtocolType
    private var instance: ProtocolType? = nil
    private let scope: FDIScope

    init(_ type: ProtocolType.Type, scope: FDIScope, factory: @escaping (Resolver) -> ProtocolType) {
        self.factory = factory
        self.scope = scope
    }

    func resolve(_ resolver: Resolver) -> ProtocolType {
        switch scope {
        case .singleton:
            if instance == nil {
                instance = factory(resolver)
            }
            return instance!
        case .transient:
            return factory(resolver)
        }
    }
}


public enum FDIScope {
    case singleton
    case transient
}
