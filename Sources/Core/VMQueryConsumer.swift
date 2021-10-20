//
//  VMQueryConsumer.swift
//  Atsani
//
//  Created by max on 2021/10/19.
//

#if canImport(Foundation)

import Foundation
import Combine

public final class VMQueryConsumer<Request, Response: Codable>: ObservableObject, VMQueryProtocol {
    
  @Published public private(set) var state: VMQueryState<Response> = .idle
  
  public var statePublisher: AnyPublisher<VMQueryState<Response>, Never> {
    return self.$state.eraseToAnyPublisher()
  }
  
  public var valuePublisher: AnyPublisher<Response, Never> {
    return self.$state
      .compactMap { $0.value }
      .eraseToAnyPublisher()
  }
  
  private let cacheKey: VMCacheKey
  
  private let anyQuery: VMAnyQuery<Request, Response>?
  
  private var cancellables = Set<AnyCancellable>()
  
  public init(cacheKey: VMCacheKey) {
    self.cacheKey = cacheKey
    
    self.anyQuery = VMQueryRegistry.shared.fetchAnyQuery(forKey: cacheKey)
    
    self.anyQuery?.statePublisher
      .sink { [weak self] (_) in
        self?.objectWillChange.send()
      }
      .store(in: &self.cancellables)
  }
}

#endif
