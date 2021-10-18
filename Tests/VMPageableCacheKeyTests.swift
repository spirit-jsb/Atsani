//
//  VMPageableCacheKeyTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/18.
//

import XCTest
@testable import Atsani

class VMPageableCacheKeyTests: XCTestCase {

  func test_pageableCacheKey() {
    let limit = 10
    let offset = 10
    
    let pageableCacheKey = VMPageableCacheKey(limit: limit, offset: offset)
    XCTAssertEqual(pageableCacheKey.keyValue, "\(limit)_\(offset)")
    
    let nextPageableCacheKey = pageableCacheKey.next
    XCTAssertEqual(nextPageableCacheKey.keyValue, "\(limit)_\(offset + limit)")
    
    let firstPageableCacheKey = pageableCacheKey.first
    XCTAssertEqual(firstPageableCacheKey.keyValue, "\(limit)_0")
  }
}
