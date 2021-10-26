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
  
  public func appendingPageable(_ pageable: AtsaniKeyProtocol) -> AtsaniKey {
    return AtsaniKey(value: "\(self.keyValue)::\(pageable.keyValue)")
  }
  
  public func appendingSuffix(_ suffix: String) -> AtsaniKey {
    return AtsaniKey(value: "\(self.keyValue)::\(suffix)")
  }
}

internal extension AtsaniKey {
  
  var invalidateQuery: Notification.Name {
    return .init(rawValue: "\(self.keyValue)::invalidateQueryNotification")
  }
}

#endif
