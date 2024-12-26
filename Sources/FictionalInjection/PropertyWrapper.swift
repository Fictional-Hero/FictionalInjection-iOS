@propertyWrapper
public struct Inject<T> {
    public var wrappedValue: T!

    public init(_ name: String = "") {
        self.wrappedValue = Container.bucket.resolve(T.self, name: name)
    }
}
