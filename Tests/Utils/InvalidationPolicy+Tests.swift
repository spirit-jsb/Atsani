//
//  InvalidationPolicy+Tests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/21.
//

#if canImport(Foundation) && canImport(Atsani)

import Foundation
import Atsani

extension VMCacheConfiguration.InvalidationPolicy: Equatable {
  
  public static func == (lhs: VMCacheConfiguration.InvalidationPolicy, rhs: VMCacheConfiguration.InvalidationPolicy) -> Bool {
    switch (lhs, rhs) {
      case (.notInvalidation, .notInvalidation):
        return true
      case (.expire(let lhsExpireTimestamp), .expire(let rhsExpireTimestamp)):
        return lhsExpireTimestamp == rhsExpireTimestamp
      default:
        return false
    }
  }
}

#endif
