import XCTest
@testable import FictionalInjection

protocol TestProcotol {}

final class FictionalInjectionTests: XCTestCase {
    
    func testConcurrentBinding() {
        let container = FDIContainer()
        let expectation = XCTestExpectation(description: "Concurrent binding should succeed")
        expectation.expectedFulfillmentCount = 50

        let queue = DispatchQueue.global(qos: .userInitiated)
        for i in 0..<50 {
            queue.async {
                container.bind(String.self, name: "Binding \(i)") { _ in
                    "Resolved \(i)"
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(container.factories.count, 50)
    }
    
    func testConcurrentResolution() {
        let container = FDIContainer()
        container.bind(String.self) { _ in
            "Resolved String"
        }
        
        let expectation = XCTestExpectation(description: "Concurrent resolution should succeed")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        for _ in 0..<100 {
            queue.async {
                let resolvedValue: String = container.resolve(String.self)
                XCTAssertEqual(resolvedValue, "Resolved String")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    
    func testContainerResolvesCorrectType() {
        let container = FDIContainer()
        
        class TestClass: TestProcotol {}
        container.bind(TestProcotol.self) { _ in
            TestClass()
        }
        
        let resolvedService = container.resolve(TestProcotol.self)
        XCTAssertNotNil(resolvedService)
        XCTAssertTrue(resolvedService is TestClass)
    }
    
    func testContainerResolvesOptionalType() {
        let container = FDIContainer()
        
        class TestClass {}
        container.bind(TestClass.self) { _ in
            TestClass()
        }
        
        let resolvedService = container.resolveOptional(TestClass.self)
        XCTAssertNotNil(resolvedService)
    }
    
    func testContainerReturnsNilIfOptionalTypeNotBound() {
        let container = FDIContainer()
        
        class TestClass {}
        container.bind(TestClass.self) { _ in
            TestClass()
        }
        
        let resolvedService = container.resolveOptional(TestProcotol.self)
        XCTAssertNil(resolvedService)
    }
    
    func testContainerResolvesUniqueTransientObject() {
        let container = FDIContainer()
        
        class TestClass: Equatable {
            let id = UUID()
            static func == (lhs: TestClass, rhs: TestClass) -> Bool {
                lhs.id == rhs.id
            }
        }
        
        container.bind(TestClass.self) { _ in
            TestClass()
        }
        
        let resolvedService = container.resolve(TestClass.self)
        let resolvedService2 = container.resolve(TestClass.self)
        XCTAssertNotEqual(resolvedService, resolvedService2)
    }
    
    func testContainerResolvesSameSingletonObject() {
        let container = FDIContainer()
        
        class TestClass: Equatable {
            let id = UUID()
            static func == (lhs: TestClass, rhs: TestClass) -> Bool {
                lhs.id == rhs.id
            }
        }
        
        container.bind(TestClass.self, scope: .singleton) { _ in
            TestClass()
        }
        
        let resolvedService = container.resolve(TestClass.self)
        let resolvedService2 = container.resolve(TestClass.self)
        XCTAssertEqual(resolvedService, resolvedService2)
    }
    
    func testTransientObjectIsDeallocated() {
        class TestClass {}
        weak var weakReference: TestClass?

        let container = FDIContainer()
        container.bind(TestClass.self) { _ in
            TestClass()
        }
        
        autoreleasepool {
            let instance = container.resolve(TestClass.self)
            weakReference = instance
            XCTAssertNotNil(weakReference)
        }
        
        XCTAssertNil(weakReference)
    }
    
    func testSingletonObjectIsNotDeallocated() {
        class TestClass {}
        weak var weakReference: TestClass?

        let container = FDIContainer()
        container.bind(TestClass.self, scope: .singleton) { _ in
            TestClass()
        }
        
        autoreleasepool {
            let instance = container.resolve(TestClass.self)
            weakReference = instance
            XCTAssertNotNil(weakReference)
        }
        
        XCTAssertNotNil(weakReference)
    }
    
    func testGenericFactoryReleasesObject() {
        class TestClass {}
        weak var weakReference: TestClass?

        autoreleasepool {
            let factory = GenericFactory(TestClass.self, scope: .singleton) { _ in
                let instance = TestClass()
                weakReference = instance
                return instance
            }

            let resolver = FDIContainer()
            let strongReference = factory.resolve(resolver)
            XCTAssertNotNil(weakReference)
        }

        XCTAssertNil(weakReference)
    }
    
    func testFactoryWrapperReleasesObject() {
        class TestClass {}
        weak var weakReference: TestClass?

        autoreleasepool {
            let factory = GenericFactory(TestClass.self, scope: .singleton) { _ in
                let instance = TestClass()
                weakReference = instance
                return instance
            }
            let wrapper = FactoryWrapper(factory, name: "test")
            let resolver = FDIContainer()
            let strongReference = wrapper.resolve(resolver) as TestClass
            XCTAssertNotNil(weakReference)
        }

        XCTAssertNil(weakReference)
    }


}
