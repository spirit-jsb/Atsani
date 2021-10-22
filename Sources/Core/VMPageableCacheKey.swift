//
//  VMPageableCacheKey.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation)

import Foundation

public struct VMPageableCacheKey: PageableAtsaniKeyProtocol {
  
  public let limit: Int
  public let offset: Int
  
  public var keyValue: String {
    return "\(self.limit)_\(self.offset)"
  }
  
  public var first: Self {
    return VMPageableCacheKey(limit: self.limit, offset: 0)
  }
  
  public var next: Self {
    return VMPageableCacheKey(limit: self.limit, offset: self.offset + self.limit)
  }
  
  public init(limit: Int, offset: Int) {
    self.limit = limit
    self.offset = offset
  }
}

#endif
