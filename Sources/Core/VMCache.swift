//
//  VMCache.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation)

import Foundation

public protocol VMCacheProtocol {
  
  // 缓存数据
  func cache<Value: Codable>(forKey key: VMCacheKey, value: Value, cacheDate: Date)
  // 失效缓存数据
  func invalidate(forKey key: VMCacheKey)
  
  // 获取缓存数据
  func fetchCache<Value: Codable>(forKey key: VMCacheKey) -> Value?
  
  // 验证缓存数据是否有效
  func isCacheValueValid(forKey key: VMCacheKey, validDate: Date, invalidationPolicy: VMCacheConfiguration.InvalidationPolicy) -> Bool
}

#endif
