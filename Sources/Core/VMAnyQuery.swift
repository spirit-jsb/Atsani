//
//  VMAnyQuery.swift
//  Atsani
//
//  Created by max on 2021/10/19.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public final class VMAnyQuery<RequestContext, Response>: VMQueryProtocol {
  
  typealias StateProvider = () -> VMQueryState<Response>
  typealias StatePublisherProvider = () -> AnyPublisher<VMQueryState<Response>, Never>
  
  public var state: VMQueryState<Response> {
    return self.stateProvider()
  }
  
  public var statePublisher: AnyPublisher<VMQueryState<Response>, Never> {
    return self.statePublisherProvider()
  }
  
  private let stateProvider: StateProvider
  private let statePublisherProvider: StatePublisherProvider
  
  init(stateProvider: @escaping StateProvider, statePublisherProvider: @escaping StatePublisherProvider) {
    self.stateProvider = stateProvider
    self.statePublisherProvider = statePublisherProvider
  }
}

#endif
