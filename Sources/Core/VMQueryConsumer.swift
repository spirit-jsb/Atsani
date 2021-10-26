//
//  VMQueryConsumer.swift
//  Atsani
//
//  Created by max on 2021/10/19.
//

#if canImport(Foundation)

import Foundation
import Combine

public final class VMQueryConsumer<RequestContext, Response: Codable>: ObservableObject, VMQueryProtocol {
  
  public var state: VMQueryState<Response> {
    return self.anyQuery.state
  }
  
  public var statePublisher: AnyPublisher<VMQueryState<Response>, Never> {
    return self.anyQuery.statePublisher.eraseToAnyPublisher()
  }
  
  public var valuePublisher: AnyPublisher<Response, Error> {
    return self.anyQuery.statePublisher
      .tryCompactMap { try $0.value() }
      .eraseToAnyPublisher()
  }
  
  private let queryIdentifier: AtsaniKey
  
  private let anyQuery: VMAnyQuery<RequestContext, Response>
  
  private var cancellables = Set<AnyCancellable>()
  
  public init(queryIdentifier: AtsaniKey) throws {
    self.queryIdentifier = queryIdentifier
    
    guard let registeredQuery: VMAnyQuery<RequestContext, Response> = VMQueryRegistry.shared.fetchAnyQuery(forIdentifier: queryIdentifier) else {
      throw AtsaniError.fetchRegisteredQueryFailure
    }
    
    self.anyQuery = registeredQuery
    
    registeredQuery.statePublisher
      .sink { [weak self] (_) in
        self?.objectWillChange.send()
      }
      .store(in: &self.cancellables)
  }
}

#endif
