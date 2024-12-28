import XCTest
@testable import FictionalInjection

protocol TestProcotol {}

final class FictionalInjectionTests: XCTestCase {
    
    func testContainerResolvesCorrectType() {
        var container = FDIContainer()
        
        class TestClass: TestProcotol {}
        container.bind(TestProcotol.self) { _ in
            TestClass()
        }
        
        let resolvedService = container.resolve(TestProcotol.self)
        XCTAssertNotNil(resolvedService)
        XCTAssertTrue(resolvedService is TestClass)
    }
    
    func testTransientObjectIsDeallocated() {
        class TestClass {}
        weak var weakReference: TestClass?

        var container = FDIContainer()
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
    
    func testGenericFactoryReleasesObject() {
        class TestClass {}
        weak var weakReference: TestClass?

        autoreleasepool {
            let factory = GenericFactory(TestClass.self) { _ in
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
            let factory = GenericFactory(TestClass.self) { _ in
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
