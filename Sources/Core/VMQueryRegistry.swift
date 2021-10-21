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
  
  private var registries: [String: Any] = [:]
  
  init() {
    
  }
  
  func register<RequestContext, Response>(forIdentifier identifier: String, anyQuery: VMAnyQuery<RequestContext, Response>) {
    self.registries[identifier] = anyQuery
  }
  
  func unregister(forIdentifier identifier: String) {
    self.registries.removeValue(forKey: identifier)
  }
  
  func fetchAnyQuery<RequestContext, Response>(forIdentifier identifier: String) -> VMAnyQuery<RequestContext, Response>? {
    return self.registries[identifier] as? VMAnyQuery<RequestContext, Response>
  }
}

#endif
