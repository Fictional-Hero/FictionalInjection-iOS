@propertyWrapper
public struct FDIResolve<T> {
    public var wrappedValue: T!

    public init(_ name: String = "") {
        self.wrappedValue = FDIContainer.shared.resolve(T.self, name: name)
    }
}
