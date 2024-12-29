@propertyWrapper
public struct FDIResolve<T> {
    public var wrappedValue: T!

    public init(_ name: String = "", container: FDIContainer = FDIContainer.shared) {
        self.wrappedValue = container.resolve(T.self, name: name)
    }
}
