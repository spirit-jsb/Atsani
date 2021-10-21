//
//  VMInMemoryCache.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation)

import Foundation

public final class VMInMemoryCache: VMCacheProtocol {
  
  public static let shared = VMInMemoryCache()
  
  private var caches: [AtsaniKey: (value: Any?, cacheDate: Date)] = [:]
  
  private init() {
    
  }
  
  public func cache<Value>(forKey key: AtsaniKey, value: Value, cacheDate: Date) where Value : Decodable, Value : Encodable {
    self.caches[key] = (value: value, cacheDate: cacheDate)
  }
  
  public func invalidate(forKey key: AtsaniKey) {
    self.caches[key] = nil
  }
  
  public func fetchCache<Value>(forKey key: AtsaniKey) -> Value? where Value : Decodable, Value : Encodable {
    return self.caches[key]?.value as? Value
  }
  
  public func isCacheValueValid(forKey key: AtsaniKey, validDate: Date, invalidationPolicy: VMCacheConfiguration.InvalidationPolicy) -> Bool {
    switch invalidationPolicy {
      case .notInvalidation:
        return true
      case .expire(let expireTimestamp):
        let cache = self.caches[key]
        
        // 如果无法获取缓存时间, 则认为缓存无效
        guard let cacheDate = cache?.cacheDate else {
          return false
        }
        
        // 计算出缓存失效时间
        let expireDate = Calendar.current.date(byAdding: .second, value: Int(expireTimestamp), to: cacheDate)
        
        // 如果验证时间大于缓存过期时间则认为缓存过期
        return expireDate?.compare(validDate) == .orderedDescending
    }
  }
}

#endif
