//
//  VMCacheConfigurationTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/21.
//

import XCTest
@testable import Atsani

class VMCacheConfigurationTests: XCTestCase {
  
  func test_defaultCacheConfiguration() {
    let `default` = VMCacheConfiguration.default
    
    XCTAssertEqual(`default`.invalidationPolicy, .notInvalidation)
    XCTAssertEqual(`default`.usagePolicy, .useWhenLoadFails)
  }
}
