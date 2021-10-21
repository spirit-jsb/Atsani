//
//  VMQuery.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public final class VMQuery<RequestContext, Response: Codable>: ObservableObject, VMQueryProtocol {
  
  public typealias CacheKeyHandler = (VMCacheKey, RequestContext) -> VMCacheKey
  public typealias Querier = (RequestContext) -> AnyPublisher<Response, Error>
  
  public enum QueryBehavior {
    case startWhenRequery
    case startImmediately(RequestContext)
  }
  
  @Published public private(set) var state: VMQueryState<Response> = .idle
  
  public var statePublisher: AnyPublisher<VMQueryState<Response>, Never> {
    return self.$state.eraseToAnyPublisher()
  }
  
  public var valuePublisher: AnyPublisher<Response, Never> {
    return self.$state
      .compactMap { $0.value }
      .eraseToAnyPublisher()
  }
  
  private let queryIdentifier: String
  
  private let cacheKey: VMCacheKey
  private let cacheKeyHandler: CacheKeyHandler
  private let cache: VMCacheProtocol
  private let cacheConfiguration: VMCacheConfiguration
  
  private let querier: Querier
  
  private var lastRequestContext: RequestContext?
  
  private var cancellables = Set<AnyCancellable>()
  
  public init(
    queryIdentifier: String,
    cacheKeyHandler: @escaping CacheKeyHandler = { (cacheKey, _) in cacheKey },
    cache: VMCacheProtocol = VMUserDefaultsCache.shared,
    cacheConfiguration: VMCacheConfiguration = VMCacheConfiguration.`default`,
    queryBehavior: QueryBehavior = .startWhenRequery,
    querier: @escaping Querier
  ) {
    self.queryIdentifier = queryIdentifier
    
    self.cacheKey = VMCacheKey(value: queryIdentifier)
    self.cacheKeyHandler = cacheKeyHandler
    self.cache = cache
    self.cacheConfiguration = cacheConfiguration
    
    self.querier = querier
    
    self.startQuery(withQueryBehavior: queryBehavior)
    
    VMQueryRegistry.shared.register(forIdentifier: queryIdentifier, anyQuery: self.eraseToAnyQuery())
  }
  
  deinit {
    self.cancellables.forEach { $0.cancel() }
    
    VMQueryRegistry.shared.unregister(forIdentifier: self.queryIdentifier)
  }
  
  public func requery(forRequestContext requestContext: RequestContext) {
    self.lastRequestContext = requestContext
    
    if self.cacheConfiguration.usagePolicy == .useWhenLoadFails || self.cacheConfiguration.usagePolicy == .useThenLoad {
      self.state = .loading
    }
    
    self.performQuery(forRequestContext: requestContext)
  }
  
  func eraseToAnyQuery() -> VMAnyQuery<RequestContext, Response> {
    return VMAnyQuery {
      return self.state
    } statePublisherProvider: {
      return self.statePublisher
    }
  }
  
  private func startQuery(withQueryBehavior queryBehavior: QueryBehavior) {
    switch queryBehavior {
      case .startWhenRequery:
        break
      case .startImmediately(let requestContext):
        self.requery(forRequestContext: requestContext)
    }
  }
  
  private func isCacheValueValid(forKey key: VMCacheKey) -> Bool {
    return self.cache.isCacheValueValid(forKey: key, validDate: Date(), invalidationPolicy: self.cacheConfiguration.invalidationPolicy)
  }
  
  private func getCacheIfPossibly(forKey key: VMCacheKey) -> Response? {
    return self.isCacheValueValid(forKey: key) ? self.cache.fetchCache(forKey: key) : nil
  }
  
  private func performQuery(forRequestContext requestContext: RequestContext) {
    let cacheKey = self.cacheKeyHandler(self.cacheKey, requestContext)
    
    if self.cacheConfiguration.usagePolicy == .useDontLoad || self.cacheConfiguration.usagePolicy == .useThenLoad {
      if let cachedResponse = self.getCacheIfPossibly(forKey: cacheKey) {
        self.state = .success(cachedResponse)
      }
    }
    
    guard self.cacheConfiguration.usagePolicy != .useDontLoad else {
      return
    }
    
    self.querier(requestContext)
      .sink { (completion) in
        switch completion {
          case .failure(let error):
            if self.cacheConfiguration.usagePolicy == .useWhenLoadFails {
              if let cachedResponse = self.getCacheIfPossibly(forKey: cacheKey) {
                self.state = .success(cachedResponse)
              }
              else {
                self.state = .failure(error)
              }
            }
            else {
              self.state = .failure(error)
            }
          case .finished:
            break
        }
      } receiveValue: { (response) in
        self.state = .success(response)
        
        // 缓存数据
        self.cache.cache(forKey: cacheKey, value: response, cacheDate: Date())
      }
      .store(in: &self.cancellables)
  }
}

#endif
