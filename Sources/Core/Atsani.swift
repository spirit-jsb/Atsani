//
//  Atsani.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public protocol VMQueryProtocol {
  
  associatedtype Request
  associatedtype Response
  
  var state: VMQueryState<Response> { get }
  var statePublisher: AnyPublisher<VMQueryState<Response>, Never> { get }
}

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

public protocol VMCacheKeyProtocol {
  
  var keyValue: String { get }
}

public protocol VMPageableCacheKeyProtocol: VMCacheKeyProtocol {
  
  var first: VMPageableCacheKeyProtocol { get }
  var next: VMPageableCacheKeyProtocol { get }
}

#endif
