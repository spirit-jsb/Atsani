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
  
  private let _lock = NSLock()
  
  private var registries: [AtsaniKey: Any] = [:]
  
  init() {
    
  }
  
  // 加锁, 防止竞争 registries 引起的崩溃
  func register<RequestContext, Response>(forIdentifier identifier: AtsaniKey, anyQuery: VMAnyQuery<RequestContext, Response>) {
    self._lock.lock()
    defer {
      self._lock.unlock()
    }
    
    self.registries[identifier] = anyQuery
  }
  
  // 加锁, 防止竞争 registries 引起的崩溃
  func unregister(forIdentifier identifier: AtsaniKey) {
    self._lock.lock()
    defer {
      self._lock.unlock()
    }
    
    self.registries.removeValue(forKey: identifier)
  }
  
  func fetchAnyQuery<RequestContext, Response>(forIdentifier identifier: AtsaniKey) -> VMAnyQuery<RequestContext, Response>? {
    return self.registries[identifier] as? VMAnyQuery<RequestContext, Response>
  }
}

#endif
