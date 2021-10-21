//
//  VMQueryConsumerTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/21.
//

import XCTest
import Combine
@testable import Atsani

class VMQueryConsumerTests: XCTestCase {

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
    let expectation = expectation(description: "test queryConsumer statePublisher")
    
    let queryRegistry = VMQueryRegistry.shared
    
    let queryIdentifier = AtsaniKey(value: "com.max.jian.Atsani.unit.test")
    let anyQuery = VMAnyQuery<Void, String>(stateProvider: { self.testState }, statePublisherProvider: { self.testStatePublisher })
    
    // 注册
    queryRegistry.register(forIdentifier: queryIdentifier, anyQuery: anyQuery)
    
    let queryConsumer = VMQueryConsumer<Void, String>(queryIdentifier: queryIdentifier)
    
    var statePublisherResults: [VMQueryState<String>] = []
    queryConsumer.statePublisher
      .dropFirst()
      .sink { (state) in
        statePublisherResults.append(state)
      }
      .store(in: &self.cancellables)
    
    var valuePublisherResults: [String] = []
    queryConsumer.valuePublisher
      .sink { (value) in
        valuePublisherResults.append(value)
      }
      .store(in: &self.cancellables)
    
    self.testState = .idle
    XCTAssertEqual(queryConsumer.state, .idle)
    
    self.testState = .loading
    XCTAssertEqual(queryConsumer.state, .loading)
    
    self.testState = .success("success")
    XCTAssertEqual(queryConsumer.state, .success("success"))
    
    self.testState = .failure(AtsaniTestError.testFailure)
    XCTAssertEqual(queryConsumer.state, .failure(AtsaniTestError.testFailure))
    
    expectation.fulfill()
    
    waitForExpectations(timeout: 5) { _ in
      XCTAssertEqual(statePublisherResults, [.idle, .loading, .success("success"), .failure(AtsaniTestError.testFailure)])
      XCTAssertEqual(valuePublisherResults, ["success"])
    }
  }
}
