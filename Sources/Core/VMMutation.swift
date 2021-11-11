//
//  VMMutation.swift
//  Atsani
//
//  Created by max on 2021/10/22.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public final class VMMutation<RequestContext, Response: Codable>: ObservableObject {
  
  public typealias Querier = (RequestContext) -> AnyPublisher<Response, Error>
  public typealias Mutation = (Response, (AtsaniKey, VMQueryInvalidater<RequestContext>.InvalidationRequestContext) -> Void) -> Void
  public typealias Replace = (Response, (AtsaniKey) -> Void) -> Void
  
  @Published public private(set) var state: VMQueryState<Response> = .idle
  
  private let querier: Querier
  
  private var cancellables = Set<AnyCancellable>()
  
  public init(querier: @escaping Querier) {
    self.querier = querier
  }
  
  public func remutation(forRequestContext requestContext: RequestContext, mutation: @escaping Mutation) {
    self.state = .loading
    
    self.querier(requestContext)
      .sink { [weak self] (completion) in
        switch completion {
          case .failure(let error):
            self?.state = .failure(error)
          case .finished:
            break
        }
      } receiveValue: { [weak self] (response) in
        self?.state = .success(response)
        
        let queryInvalidater = VMQueryInvalidater<RequestContext>()
        mutation(response, queryInvalidater.invalidateQuery)
      }
      .store(in: &self.cancellables)
  }
  
  public func remutation(forRequestContext requestContext: RequestContext, replace: @escaping Replace) {
    self.state = .loading
    
    self.querier(requestContext)
      .sink { [weak self] (completion) in
        switch completion {
          case .failure(let error):
            self?.state = .failure(error)
          case .finished:
            break
        }
      } receiveValue: { [weak self] (response) in
        self?.state = .success(response)
        
        let queryInvalidater = VMQueryInvalidater<RequestContext>()
        replace(response, queryInvalidater.replaceQueryState)
      }
      .store(in: &self.cancellables)
  }
}

#endif

