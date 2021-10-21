//
//  VMAnyQueryTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/19.
//

import XCTest
import Combine
@testable import Atsani

class VMAnyQueryTests: XCTestCase {
  
  @Published private var testState: VMQueryState<String> = .idle
  
  private var testStatePublisher: AnyPublisher<VMQueryState<String>, Never> {
    return self.$testState.eraseToAnyPublisher()
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  override func tearDown() {
    super.tearDown()
    
    self.cancellables.forEach { $0.cancel() }
  }
  
  func test_anyQuery() {
    let expectation = expectation(description: "test anyQuery statePublisher")
    
    let anyQuery = VMAnyQuery<Void, String>(stateProvider: { self.testState }, statePublisherProvider: { self.testStatePublisher })
    
    var statePublisherResults: [VMQueryState<String>] = []
    anyQuery.statePublisher
      .dropFirst()
      .sink { (state) in
        statePublisherResults.append(state)
      }
      .store(in: &self.cancellables)
    
    self.testState = .idle
    XCTAssertEqual(anyQuery.state, .idle)
    
    self.testState = .loading
    XCTAssertEqual(anyQuery.state, .loading)
    
    self.testState = .success("success")
    XCTAssertEqual(anyQuery.state, .success("success"))
    
    self.testState = .failure(AtsaniTestError.testFailure)
    XCTAssertEqual(anyQuery.state, .failure(AtsaniTestError.testFailure))
    
    expectation.fulfill()
    
    waitForExpectations(timeout: 5) { _ in
      XCTAssertEqual(statePublisherResults, [.idle, .loading, .success("success"), .failure(AtsaniTestError.testFailure)])
    }
  }
}
