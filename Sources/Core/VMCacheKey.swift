//
//  VMCacheKey.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation)

import Foundation

public struct VMCacheKey: Hashable, VMCacheKeyProtocol {
  
  public let keyValue: String
  
  public init(value: String) {
    self.keyValue = value
  }
}

#endif
