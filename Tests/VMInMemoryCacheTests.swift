//
//  VMInMemoryCacheTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/18.
//

import XCTest
@testable import Atsani

class VMInMemoryCacheTests: XCTestCase {
  
  func test_inMemoryCache() {
    let inMemoryCache = VMInMemoryCache.shared
    
    let key: VMCacheKey = .init(value: "com.max.jian.Atsani.unit.test")
    let value: String = #function + String.random(length: 10)
    let cacheDate = Date()
    
    // 缓存数据
    inMemoryCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    // 查询缓存数据
    let cachedValue: String? = inMemoryCache.fetchCache(forKey: key)
    
    XCTAssertEqual(cachedValue, value)
  }
  
  func test_inMemoryCache_invalidate() {
    let inMemoryCache = VMInMemoryCache.shared
    
    let key: VMCacheKey = .init(value: "com.max.jian.Atsani.unit.test")
    let value: String = #function + String.random(length: 10)
    let cacheDate = Date()
    
    // 缓存数据
    inMemoryCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    // 查询缓存数据
    var cachedValue: String? = inMemoryCache.fetchCache(forKey: key)
    
    XCTAssertEqual(cachedValue, value)
    
    // 失效缓存数据
    inMemoryCache.invalidate(forKey: key)
    
    // 查询缓存数据
    cachedValue = inMemoryCache.fetchCache(forKey: key)
    
    XCTAssertNil(cachedValue)
  }
  
  func test_inMemoryCache_is_cache_value_valid() {
    let inMemoryCache = VMInMemoryCache.shared
    
    let key: VMCacheKey = .init(value: "com.max.jian.Atsani.unit.test")
    let value: String = #function + String.random(length: 10)
    let cacheDate = Date()
    
    // 缓存数据
    inMemoryCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    let validDate = Date()
    // 查询缓存是否失效 (notInvalidation)
    var isCacheValueValid = inMemoryCache.isCacheValueValid(forKey: key, validDate: validDate, invalidationPolicy: .notInvalidation)
    
    XCTAssertTrue(isCacheValueValid)
    
    // 查询缓存是否失效 (expire(10))
    isCacheValueValid = inMemoryCache.isCacheValueValid(forKey: key, validDate: validDate, invalidationPolicy: .expire(10))
    
    XCTAssertTrue(isCacheValueValid)
    
    // 查询缓存是否失效 (validData + 20, expire(10))
    isCacheValueValid = inMemoryCache.isCacheValueValid(forKey: key, validDate: validDate.addingTimeInterval(20), invalidationPolicy: .expire(10))
    
    XCTAssertFalse(isCacheValueValid)
    
    // 失效缓存后发起缓存验证 (缓存为 nil)
    inMemoryCache.invalidate(forKey: key)
    isCacheValueValid = inMemoryCache.isCacheValueValid(forKey: key, validDate: validDate, invalidationPolicy: .expire(10))
    
    XCTAssertFalse(isCacheValueValid)
  }
}
