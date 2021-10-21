//
//  Atsani.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public protocol AtsaniKeyProtocol {
  
  var keyValue: String { get }
}

public protocol VMQueryProtocol {
  
  associatedtype RequestContext
  associatedtype Response
  
  var state: VMQueryState<Response> { get }
  var statePublisher: AnyPublisher<VMQueryState<Response>, Never> { get }
}

public protocol VMPageableCacheKeyProtocol: AtsaniKeyProtocol {
  
  var first: Self { get }
  var next: Self { get }
}

public protocol VMCacheProtocol {
  
  // 缓存数据
  func cache<Value: Codable>(forKey key: AtsaniKey, value: Value, cacheDate: Date)
  // 失效缓存数据
  func invalidate(forKey key: AtsaniKey)
  
  // 获取缓存数据
  func fetchCache<Value: Codable>(forKey key: AtsaniKey) -> Value?
  
  // 验证缓存数据是否有效
  func isCacheValueValid(forKey key: AtsaniKey, validDate: Date, invalidationPolicy: VMCacheConfiguration.InvalidationPolicy) -> Bool
}

#endif
