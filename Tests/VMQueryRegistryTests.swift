//
//  VMQueryRegistryTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/21.
//

import XCTest
import Combine
@testable import Atsani

class VMQueryRegistryTests: XCTestCase {
  
  @Published private var testState: VMQueryState<String> = .idle
  
  private var testStatePublisher: AnyPublisher<VMQueryState<String>, Never> {
    return self.$testState.eraseToAnyPublisher()
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  override func tearDown() {
    super.tearDown()
    
    self.cancellables.forEach { $0.cancel() }
  }

  
  func test_queryRegistry() {
    let queryRegistry = VMQueryRegistry.shared
    
    let queryIdentifier = "com.max.jian.Atsani.unit.test"
    let anyQuery = VMAnyQuery<Void, String>(stateProvider: { self.testState }, statePublisherProvider: { self.testStatePublisher })
    
    // 注册
    queryRegistry.register(forIdentifier: queryIdentifier, anyQuery: anyQuery)
    
    // 查询
    var fetchResult: VMAnyQuery<Void, String>? = queryRegistry.fetchAnyQuery(forIdentifier: queryIdentifier)
    
    XCTAssertNotNil(fetchResult)
    XCTAssertEqual(fetchResult?.state, anyQuery.state)
    
    // 注册
    queryRegistry.unregister(forIdentifier: queryIdentifier)
    
    // 查询
    fetchResult = queryRegistry.fetchAnyQuery(forIdentifier: queryIdentifier)
    
    XCTAssertNil(fetchResult)
  }
}
