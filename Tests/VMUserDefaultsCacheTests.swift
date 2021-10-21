//
//  VMUserDefaultsCacheTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/18.
//

import XCTest
@testable import Atsani

class VMUserDefaultsCacheTests: XCTestCase {
  
  func test_userDefaultsCache() {
    let userDefaultsCache = VMUserDefaultsCache.shared
    
    let key: AtsaniKey = .init(value: "com.max.jian.Atsani.unit.test")
    let value: String = #function + String.random(length: 10)
    let cacheDate = Date()
    
    // 缓存数据
    userDefaultsCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    // 查询缓存数据
    let cachedValue: String? = userDefaultsCache.fetchCache(forKey: key)
    
    XCTAssertEqual(cachedValue, value)
  }
  
  func test_userDefaultsCache_invalidate() {
    let userDefaultsCache = VMUserDefaultsCache.shared
    
    let key: AtsaniKey = .init(value: "com.max.jian.Atsani.unit.test")
    let value: String = #function + String.random(length: 10)
    let cacheDate = Date()
    
    // 缓存数据
    userDefaultsCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    // 查询缓存数据
    var cachedValue: String? = userDefaultsCache.fetchCache(forKey: key)
    
    XCTAssertEqual(cachedValue, value)
    
    // 失效缓存数据
    userDefaultsCache.invalidate(forKey: key)
    
    // 查询缓存数据
    cachedValue = userDefaultsCache.fetchCache(forKey: key)
    
    XCTAssertNil(cachedValue)
  }
  
  func test_userDefaultsCache_is_cache_value_valid() {
    let userDefaultsCache = VMUserDefaultsCache.shared
    
    let key: AtsaniKey = .init(value: "com.max.jian.Atsani.unit.test")
    let value: String = #function + String.random(length: 10)
    let cacheDate = Date()
    
    // 缓存数据
    userDefaultsCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    let validDate = Date()
    // 查询缓存是否失效 (notInvalidation)
    var isCacheValueValid = userDefaultsCache.isCacheValueValid(forKey: key, validDate: validDate, invalidationPolicy: .notInvalidation)
    
    XCTAssertTrue(isCacheValueValid)
    
    // 查询缓存是否失效 (expire(10))
    isCacheValueValid = userDefaultsCache.isCacheValueValid(forKey: key, validDate: validDate, invalidationPolicy: .expire(10))
    
    XCTAssertTrue(isCacheValueValid)
    
    // 查询缓存是否失效 (validData + 20, expire(10))
    isCacheValueValid = userDefaultsCache.isCacheValueValid(forKey: key, validDate: validDate.addingTimeInterval(20), invalidationPolicy: .expire(10))
    
    XCTAssertFalse(isCacheValueValid)
    
    // 失效缓存后发起缓存验证
    userDefaultsCache.invalidate(forKey: key)
    isCacheValueValid = userDefaultsCache.isCacheValueValid(forKey: key, validDate: validDate, invalidationPolicy: .expire(10))
    
    XCTAssertFalse(isCacheValueValid)
  }
}
