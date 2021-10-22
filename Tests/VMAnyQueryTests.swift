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
  
  @Published private var state: VMQueryState<String> = .idle
  
  private var statePublisher: AnyPublisher<VMQueryState<String>, Never> {
    return self.$state.eraseToAnyPublisher()
  }
  
  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    super.tearDown()
    
    // 重制 state
    self.state = .idle

    self.cancellables.forEach { $0.cancel() }
  }
  
  func test_anyQuery() {
    let expectation = expectation(description: "test anyQuery")
    
    let anyQuery = VMAnyQuery<Void, String>(stateProvider: { self.state }, statePublisherProvider: { self.statePublisher })
    
    var stateResults: [VMQueryState<String>] = []
    anyQuery.statePublisher
      .dropFirst()
      .sink { (state) in
        stateResults.append(state)
      }
      .store(in: &self.cancellables)
    
    self.state = .idle
    XCTAssertEqual(anyQuery.state, .idle)

    self.state = .loading
    XCTAssertEqual(anyQuery.state, .loading)

    self.state = .success("success")
    XCTAssertEqual(anyQuery.state, .success("success"))

    self.state = .failure(AtsaniTestError.testFailure)
    XCTAssertEqual(anyQuery.state, .failure(AtsaniTestError.testFailure))

    expectation.fulfill()
    
    waitForExpectations(timeout: 5) { _ in
      XCTAssertEqual(stateResults, [.idle, .loading, .success("success"), .failure(AtsaniTestError.testFailure)])
    }
  }
}
