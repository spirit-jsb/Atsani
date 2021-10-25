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
    self.keyValue = value.md5()
  }
  
  public func appendingPageable(_ pageable: AtsaniKeyProtocol) -> AtsaniKey {
    return AtsaniKey(value: "\(self.keyValue)::\(pageable.keyValue)".md5())
  }
  
  public func appendingSuffix(_ suffix: String) -> AtsaniKey {
    return AtsaniKey(value: "\(self.keyValue)::\(suffix)".md5())
  }
}

internal extension AtsaniKey {
  
  var invalidateQuery: Notification.Name {
    return .init(rawValue: "\(self.keyValue)::invalidateQueryNotification".md5())
  }
}

#endif
