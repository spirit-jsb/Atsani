//
//  VMQueryTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/21.
//

import XCTest
import Combine
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import Atsani

class VMQueryTests: XCTestCase {
  
  private let queryIdentifier = AtsaniKey(value: "com.max.jian.Atsani.unit.test")
  
  private var cancellables = Set<AnyCancellable>()
  
  override func tearDown() {
    super.tearDown()
    
    VMQueryRegistry.shared.unregister(forIdentifier: self.queryIdentifier)
    
    self.cancellables.forEach { $0.cancel() }
  }
  
  func test_query() {
    let expectation = expectation(description: "test query")
    
    let randomString: String = .random(length: 10)
    self.mockRandomString(randomString: randomString)
    
    let query = VMQuery<Void, String>(
      queryIdentifier: self.queryIdentifier,
      querier: { (_) -> AnyPublisher<String, Error> in
        URLSession.shared
          .dataTaskPublisher(for: URL(string: "https://www.mock.com")!)
          .map(\.data)
          .compactMap { String(data: $0, encoding: .utf8) }
          .mapError { $0 as Error }
          .eraseToAnyPublisher()
      }
    )
    
    // 发起请求
    query.requery(forRequestContext: ())
    
    var queryStateResults: [VMQueryState<String>] = []
    query.statePublisher
      .sink { (queryState) in
        queryStateResults.append(queryState)
        
        switch queryState {
          case .failure, .success:
            expectation.fulfill()
          default:
            break
        }
      }
      .store(in: &self.cancellables)
    
    var queryValueResult: String?
    query.valuePublisher
      .sink { (value) in
        queryValueResult = value
      }
      .store(in: &self.cancellables)
    
    waitForExpectations(timeout: 5) { _ in
      XCTAssertEqual(queryStateResults, [.loading, .success(randomString)])
      XCTAssertEqual(queryValueResult, randomString)
    }
  }
  
  func test_query_useCacheWhenLoadFails() {
    let expectation = expectation(description: "test query use cache when load fails")
    
    self.mockError(AtsaniTestError.testFailure)
    
    let query = VMQuery<Void, String>(
      queryIdentifier: self.queryIdentifier,
      querier: { (_) -> AnyPublisher<String, Error> in
        URLSession.shared
          .dataTaskPublisher(for: URL(string: "https://www.mock.com")!)
          .map(\.data)
          .compactMap { String(data: $0, encoding: .utf8) }
          .mapError { $0 as Error }
          .eraseToAnyPublisher()
      }
    )
    
    // 发起请求
    query.requery(forRequestContext: ())
    
    var queryStateResults: [VMQueryState<String>] = []
    query.statePublisher
      .sink { (queryState) in
        queryStateResults.append(queryState)
        
        switch queryState {
          case .failure, .success:
            expectation.fulfill()
          default:
            break
        }
      }
      .store(in: &self.cancellables)
    
    var queryValueResult: String?
    query.valuePublisher
      .sink { (value) in
        queryValueResult = value
      }
      .store(in: &self.cancellables)
    
    waitForExpectations(timeout: 5) { _ in
      print(queryStateResults)
      //      XCTAssertEqual(queryStateResults, [.loading, .failure()])
      XCTAssertNotNil(queryValueResult)
    }
  }
  
  private func mockRandomString(randomString: String) {
    OHHTTPStubsSwift.stub { (_) in
      return true
    } response: { (request) in
      let randomStringRawData = randomString.data(using: .utf8)!
      
      let response = HTTPStubsResponse(data: randomStringRawData, statusCode: 200, headers: nil)
      
      return response
    }
  }
  
  private func mockError(_ error: Error) {
    OHHTTPStubsSwift.stub { (_) in
      return true
    } response: { (request) in
      let response = HTTPStubsResponse()
      response.error = error
      
      return response
    }
  }
}
