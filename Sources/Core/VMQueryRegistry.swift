//
//  VMQueryRegistry.swift
//  Atsani
//
//  Created by max on 2021/10/19.
//

#if canImport(Foundation)

import Foundation

class VMQueryRegistry {
  
  static let shared = VMQueryRegistry()
  
  private var registries: [VMCacheKey: Any] = [:]
  
  init() {
    
  }
  
  func register<Request, Response>(forKey key: VMCacheKey, anyQuery: VMAnyQuery<Request, Response>) {
    self.registries[key] = anyQuery
  }
   
  func unregister(forKey key: VMCacheKey) {
    self.registries.removeValue(forKey: key)
  }
  
  func fetchAnyQuery<Request, Response>(forKey key: VMCacheKey) -> VMAnyQuery<Request, Response>? {
    return self.registries[key] as? VMAnyQuery<Request, Response>
  }
}

#endif
