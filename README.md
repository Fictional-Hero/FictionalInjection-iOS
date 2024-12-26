# SwiftAutoInit
A basic container based dependency injection framework for Swift.

## Usage
### Binding a dependency with a name
Container.bucket.addToBucket(Object.self, name: BindingName.name) { resolver in
    Object(argument: resolver.resolve(Object2.self, name: BindingName.name2))
}
### Binding a dependency without a name
Container.bucket.addToBucket(Object.self) { resolver in
    Object(argument: resolver.resolve(Object2.self, name: BindingName.name2))
}


### Resolving a dependency
@Inject("bindingName") var object: Object!
