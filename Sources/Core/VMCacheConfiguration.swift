//
//  VMCacheConfiguration.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation)

import Foundation
 
public struct VMCacheConfiguration {
  
  public enum InvalidationPolicy {
    case notInvalidation        /// 缓存数据不设定失效
    case expire(TimeInterval)   /// 缓存数据设定缓存时长
  }
  
  public enum UsagePolicy {
    case useDontLoad            /// 仅使用缓存数据
    case useWhenLoadFails       /// 当查询请求失败后, 使用缓存数据
    case useThenLoad            /// 优先使用缓存数据, 而后发起查询请求
  }
  
  public static let `default` = VMCacheConfiguration(invalidationPolicy: .notInvalidation, usagePolicy: .useWhenLoadFails)
  
  let invalidationPolicy: InvalidationPolicy
  let usagePolicy: UsagePolicy
  
  public init(invalidationPolicy: InvalidationPolicy, usagePolicy: UsagePolicy) {
    self.invalidationPolicy = invalidationPolicy
    self.usagePolicy = usagePolicy
  }
}

#endif
