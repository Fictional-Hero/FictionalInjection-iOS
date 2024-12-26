public protocol Resolver {
    func resolve<ProtocolType>(_ type: ProtocolType.Type) -> ProtocolType
    func resolve<ProtocolType>(_ type: ProtocolType.Type, name: String) -> ProtocolType
}
