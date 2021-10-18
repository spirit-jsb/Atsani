//
//  VMCacheTests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/18.
//

import XCTest
@testable import Atsani

class VMCacheTests: XCTestCase {
  
  func test_cache() {
    let globalCache = VMCache.global
    
    let key: VMCacheKey = .init(value: "com.max.jian.Atsani.unit.test")
    let value: String = #function + String.random(length: 10)
    let cacheDate = Date()
    
    // 内存缓存数据
    globalCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    // 查询内存缓存数据
    let inMemoryCachedValue: String? = globalCache.fetchCache(forKey: key)
    
    XCTAssertEqual(inMemoryCachedValue, value)
    
    VMCache.setGlobal(.userDefaults)
    
    // 磁盘缓存数据
    globalCache.cache(forKey: key, value: value, cacheDate: cacheDate)
    
    // 查询磁盘缓存数据
    let userDefaultsCachedValue: String? = globalCache.fetchCache(forKey: key)
    
    XCTAssertEqual(userDefaultsCachedValue, value)
  }
}
