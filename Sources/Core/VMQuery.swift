//
//  VMQuery.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public final class VMQuery<Request, Response: Codable>: ObservableObject, VMQueryProtocol {
  
  public typealias CacheKeyHandler = (VMCacheKey, Request) -> VMCacheKey
  public typealias Querier = (Request) -> AnyPublisher<Response, Error>
  
  public enum QueryBehavior {
    case startWhenRequery
    case startImmediately(Request)
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
  
  private let cacheKey: VMCacheKey
  private let cacheKeyHandler: CacheKeyHandler
  private let cache: VMCacheProtocol
  private let cacheConfiguration: VMCacheConfiguration
  
  private let querier: Querier
  
  private var lastRequest: Request?
  
  private var cancellables = Set<AnyCancellable>()
  
  public init(
    cacheKey: VMCacheKey,
    cacheKeyHandler: @escaping CacheKeyHandler = { (cacheKey, _) in cacheKey },
    cache: VMCacheProtocol = VMUserDefaultsCache.shared,
    cacheConfiguration: VMCacheConfiguration = VMCacheConfiguration.`default`,
    queryBehavior: QueryBehavior = .startWhenRequery,
    querier: @escaping Querier
  ) {
    self.cacheKey = cacheKey
    self.cacheKeyHandler = cacheKeyHandler
    self.cache = cache
    self.cacheConfiguration = cacheConfiguration
    self.querier = querier
    
    self.startQuery(withQueryBehavior: queryBehavior)
    
    VMQueryRegistry.shared.register(forKey: cacheKey, anyQuery: self.eraseToAnyQuery())
  }
  
  deinit {
    VMQueryRegistry.shared.unregister(forKey: self.cacheKey)
  }
  
  public func requery(forRequest request: Request) {
    self.lastRequest = request
    
    if self.cacheConfiguration.usagePolicy == .useWhenLoadFails {
      self.state = .loading
    }
    
    self.performQuery(forRequest: request)
  }
  
  private func startQuery(withQueryBehavior queryBehavior: QueryBehavior) {
    switch queryBehavior {
      case .startWhenRequery:
        break
      case .startImmediately(let request):
        self.requery(forRequest: request)
    }
  }
  
  private func isCacheValueValid(forKey key: VMCacheKey) -> Bool {
    return self.cache.isCacheValueValid(forKey: key, validDate: Date(), invalidationPolicy: self.cacheConfiguration.invalidationPolicy)
  }
  
  private func getCacheIfPossibly(forKey key: VMCacheKey) -> Response? {
    return self.isCacheValueValid(forKey: key) ? self.cache.fetchCache(forKey: key) : nil
  }
    
  private func performQuery(forRequest request: Request) {
    let cacheKey = self.cacheKeyHandler(self.cacheKey, request)
    
    if self.cacheConfiguration.usagePolicy == .useDontLoad || self.cacheConfiguration.usagePolicy == .useThenLoad {
      if let cachedResponse = self.getCacheIfPossibly(forKey: self.cacheKey) {
        self.state = .success(cachedResponse)
      }
    }
    
    if self.cacheConfiguration.usagePolicy == .useDontLoad, let cachedResponse = self.getCacheIfPossibly(forKey: self.cacheKey) {
      self.state = .success(cachedResponse)
      
      return
    }
    
    if self.cacheConfiguration.usagePolicy == .useThenLoad, let cachedResponse = self.getCacheIfPossibly(forKey: cacheKey) {
      self.state = .success(cachedResponse)
    }
    
    self.querier(request)
      .eraseToAnyPublisher()
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

extension VMQueryProtocol {
  
  func eraseToAnyQuery() -> VMAnyQuery<Request, Response> {
    return VMAnyQuery {
      return self.state
    } statePublisherProvider: {
      return self.statePublisher
    }
  }
}

#endif
