//
//  VMQueryInvalidater.swift
//  Atsani
//
//  Created by max on 2021/10/19.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public struct VMQueryInvalidater<RequestContext> {
  
  public enum InvalidationRequestContext {
    case last
    case new(RequestContext)
  }
  
  public init() {
    
  }
  
  public func invalidateQuery(forIdentifier identifier: AtsaniKey, requestContext: InvalidationRequestContext) {
    NotificationCenter.default.post(name: identifier.invalidateQuery, object: requestContext)
  }
}

extension VMQueryInvalidateListener {
  
  func queryInvalidateListener(forIdentifier identifier: AtsaniKey) -> AnyPublisher<VMQueryInvalidater<RequestContext>.InvalidationRequestContext, Never> {
    NotificationCenter.default.publisher(for: identifier.invalidateQuery)
      .compactMap { $0.object as? VMQueryInvalidater<RequestContext>.InvalidationRequestContext }
      .eraseToAnyPublisher()
  }
}

#endif
