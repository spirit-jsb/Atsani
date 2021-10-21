//
//  VMQueryInvalidaterTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/21.
//

import XCTest
import Combine
@testable import Atsani

class VMQueryInvalidaterTests: XCTestCase {
  
  private var cancellables = Set<AnyCancellable>()
  
  override func tearDown() {
    super.tearDown()
    
    self.cancellables.forEach { $0.cancel() }
  }
  
  func test_queryInvalidater() {
    let expectation = expectation(description: "test queryInvalidater")
    
    let queryInvalidater = VMQueryInvalidater<String>()
    
    let queryIdentifier: AtsaniKey = .init(value: "com.max.jian.Atsani.unit.test")
    
    var invalidationRequestContextResults: [String] = []
    NotificationCenter.default.publisher(for: queryIdentifier.invalidateQuery)
      .compactMap { $0.object as? VMQueryInvalidater<String>.InvalidationRequestContext }
      .sink { (invalidationRequestContext) in
        switch invalidationRequestContext {
          case .last:
            invalidationRequestContextResults.append("last")
          case .new(let requestContext):
            invalidationRequestContextResults.append(requestContext)
        }
      }
      .store(in: &self.cancellables)
    
    queryInvalidater.invalidateQuery(forIdentifier: queryIdentifier, requestContext: .last)
    queryInvalidater.invalidateQuery(forIdentifier: queryIdentifier, requestContext: .new("new"))
    
    expectation.fulfill()
    
    waitForExpectations(timeout: 5) { _ in
      XCTAssertEqual(invalidationRequestContextResults, ["last", "new"])
    }
  }
}
