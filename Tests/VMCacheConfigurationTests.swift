//
//  VMCacheConfigurationTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/22.
//

import XCTest
@testable import Atsani

class VMCacheConfigurationTests: XCTestCase {

  func test_defaultCacheConfiguration() {
    let defaultCacheConfiguration = VMCacheConfiguration.default
    
    XCTAssertEqual(defaultCacheConfiguration.invalidationPolicy, .notInvalidation)
    XCTAssertEqual(defaultCacheConfiguration.usagePolicy, .useWhenLoadFails)
  }
}
