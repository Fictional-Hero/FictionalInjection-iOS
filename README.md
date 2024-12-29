# FDIContainer Dependency Injection Framework

FDIContainer is a lightweight, container-based dependency injection framework for Swift, designed to simplify dependency management in your applications.

## Features
- Centralized dependency management with a shared container.
- Support for scoped dependencies (e.g., transient).
- Property wrapper for easy dependency resolution.
- Type-safe API with compile-time guarantees.

## Installation
Add FDIContainer to your project via your preferred dependency manager.

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/Fictional-Hero/FictionalInjection-iOS.git", from: "1.0.0")
]
```

## Getting Started

### Setting Up Dependencies
Dependencies are registered in the `FDIContainer` using the `bind` method.

#### Example
```swift
FDIContainer.shared.bind(ServiceProtocol.self) { _ in
    ServiceImplementation()
}
```

- **Parameters**:
  - `type`: The protocol or type to bind.
  - `scope`: Optional. Specifies the lifecycle of the dependency. Default is `.transient`.
  - `name`: Optional. A unique name to distinguish between multiple bindings of the same type.
  - `factory`: A closure that provides an instance of the dependency.

### Resolving Dependencies
You can resolve dependencies using the `resolve` method:

#### Example
```swift
let service: ServiceProtocol = FDIContainer.shared.resolve(ServiceProtocol.self)
```

- **Parameters**:
  - `type`: The protocol or type to resolve.
  - `name`: Optional. A unique name to resolve a specific instance.

### Using the Property Wrapper
Simplify dependency resolution with the `@FDIResolve` property wrapper.

#### Example
```swift
class MyClass {
    @FDIResolve var service: ServiceProtocol

    func doSomething() {
        service.performTask()
    }
}
```

- **Parameters**:
  - `name`: Optional. The name of the binding to resolve.
  - `container`: Optional. The container to use for resolution. Defaults to the shared container.

### Dependency Scopes
FDIContainer supports scoped dependencies via the `FDIScope` enumeration:
- `.transient`: A new instance is created every time the dependency is resolved.

## Example

```swift
// Define a protocol
protocol ServiceProtocol {
    func performTask()
}

// Implement the protocol
class ServiceImplementation: ServiceProtocol {
    func performTask() {
        print("Task performed!")
    }
}

// Register the service
FDIContainer.shared.bind(ServiceProtocol.self) { _ in
    ServiceImplementation()
}

// Resolve the service
let service: ServiceProtocol = FDIContainer.shared.resolve(ServiceProtocol.self)
service.performTask() // Output: Task performed!

// Using @FDIResolve
class ViewController {
    @FDIResolve var service: ServiceProtocol

    func viewDidLoad() {
        service.performTask()
    }
}
```
- `.singleton`: The same instance is created every time the dependency is resolved.

## Example

```swift
// Define a protocol
protocol ServiceProtocol {
    func performTask()
}

// Implement the protocol
class ServiceImplementation: ServiceProtocol {
    func performTask() {
        print("Task performed!")
    }
}

// Register the service
FDIContainer.shared.bind(ServiceProtocol.self, scope: .singleton) { _ in
    ServiceImplementation()
}

// Resolve the service
let service: ServiceProtocol = FDIContainer.shared.resolve(ServiceProtocol.self)
service.performTask() // Output: Task performed!

// Using @FDIResolve
class ViewController {
    @FDIResolve var service: ServiceProtocol

    func viewDidLoad() {
        service.performTask()
    }
}
```

## Error Handling
- Attempting to resolve a dependency that has not been registered will result in a runtime `fatalError`.
- Ensure all dependencies are registered before resolution.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Enjoy simplified dependency management with FDIContainer!

