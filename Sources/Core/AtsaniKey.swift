//
//  AtsaniKey.swift
//  Atsani
//
//  Created by max on 2021/10/21.
//

#if canImport(Foundation)

import Foundation

public struct AtsaniKey: Hashable, AtsaniKeyProtocol {
  
  public let keyValue: String
  
  public init(value: String) {
    self.keyValue = value
  }
  
  public func appending(_ key: AtsaniKeyProtocol) -> AtsaniKey {
    return AtsaniKey(value: "\(self.keyValue)::\(key.keyValue)")
  }
}

internal extension AtsaniKey {
  
  var invalidateQuery: Notification.Name {
    return .init(rawValue: "\(self.keyValue)_invalidate_query_notification")
  }
}

#endif
