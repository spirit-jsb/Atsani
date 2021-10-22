//
//  VMUserDefaultsCache.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation)

import Foundation

public final class VMUserDefaultsCache: VMCacheProtocol {
  
  public static let shared = VMUserDefaultsCache()
  
  private init() {
    
  }
  
  public func cache<Value>(forKey key: AtsaniKey, value: Value, cacheDate: Date) where Value : Decodable, Value : Encodable {
    guard let data = try? JSONEncoder().encode(value) else {
      return
    }
    
    UserDefaults.standard.set(data, forKey: key.keyValue)
    UserDefaults.standard.set(cacheDate, forKey: key.cacheDateKeyValue)
    UserDefaults.standard.synchronize()
  }
  
  public func invalidate(forKey key: AtsaniKey) {
    UserDefaults.standard.removeObject(forKey: key.keyValue)
    UserDefaults.standard.removeObject(forKey: key.cacheDateKeyValue)
  }
  
  public func fetchCache<Value>(forKey key: AtsaniKey) -> Value? where Value : Decodable, Value : Encodable {
    guard let data = UserDefaults.standard.data(forKey: key.keyValue) else {
      return nil
    }
    
    return try? JSONDecoder().decode(Value.self, from: data)
  }
  
  public func isCacheValueValid(forKey key: AtsaniKey, validDate: Date, invalidationPolicy: VMCacheConfiguration.InvalidationPolicy) -> Bool {
    guard let _ = UserDefaults.standard.value(forKey: <#T##String#>)
    switch invalidationPolicy {
      case .notInvalidation:
        return self.caches[key] != nil
      case .expire(let expireTimestamp):
        // 如果无法获取缓存时间, 则认为缓存无效
        guard let cacheDate = UserDefaults.standard.value(forKey: key.cacheDateKeyValue) as? Date else {
          return false
        }
        
        // 计算出缓存失效时间
        let expireDate = Calendar.current.date(byAdding: .second, value: Int(expireTimestamp), to: cacheDate)
        
        // 如果验证时间大于缓存过期时间则认为缓存过期
        return expireDate?.compare(validDate) == .orderedDescending
    }
  }
}

fileprivate extension AtsaniKey {
  
  var cacheDateKeyValue: String {
    return "\(self.keyValue)::cacheDate".md5()
  }
}

#endif
