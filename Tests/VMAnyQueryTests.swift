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

  private var cancellables = Set<AnyCancellable>()
  
  override func tearDown() {
    super.tearDown()
    
    self.cancellables.forEach { $0.cancel() }
  }
  
  func test_anyQuery() {    
    let queryState: VMQueryState<String>?
    let queryStatePublisher: AnyPublisher<VMQueryState<String>, Never>?
    
    let anyQuery = VMAnyQuery<Any, String> {
      return VMQueryState<String>.idle
    } statePublisherProvider: {
      return Just<VMQueryState<String>>(.loading).eraseToAnyPublisher()
    }
    
    queryState = anyQuery.state
        
    waitForExpectations(timeout: 5) { _ in
      
    }
  }
}
