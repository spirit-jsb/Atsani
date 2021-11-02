//
//  VMQuery.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public final class VMQuery<RequestContext, Response: Codable>: ObservableObject, VMQueryProtocol, VMQueryInvalidateListener {
  
  public typealias CacheKeyHandler = (AtsaniKey, RequestContext) -> AtsaniKey
  public typealias Querier = (RequestContext) -> AnyPublisher<Response, Error>
  
  public enum QueryBehavior {
    case startWhenRequery
    case startImmediately(RequestContext)
  }
  
  @Published public private(set) var state: VMQueryState<Response> = .idle
  
  public var statePublisher: AnyPublisher<VMQueryState<Response>, Never> {
    return self.$state.eraseToAnyPublisher()
  }
  
  public var valuePublisher: AnyPublisher<Response, Error> {
    return self.$state
      .tryCompactMap { try $0.value() }
      .eraseToAnyPublisher()
  }
  
  private let queryIdentifier: AtsaniKey
  
  private let cacheKeyHandler: CacheKeyHandler
  private let cache: VMCacheProtocol
  private let cacheConfiguration: VMCacheConfiguration
  
  private let querier: Querier
  
  private var lastRequestContext: RequestContext?
  
  private var cancellables = Set<AnyCancellable>()
  
  public init(
    queryIdentifier: AtsaniKey,
    cacheKeyHandler: @escaping CacheKeyHandler = { (cacheKey, _) in cacheKey },
    cache: VMCacheProtocol = VMUserDefaultsCache.shared,
    cacheConfiguration: VMCacheConfiguration = VMCacheConfiguration.`default`,
    queryBehavior: QueryBehavior = .startWhenRequery,
    querier: @escaping Querier
  ) {
    self.queryIdentifier = queryIdentifier
    
    self.cacheKeyHandler = cacheKeyHandler
    self.cache = cache
    self.cacheConfiguration = cacheConfiguration
    
    self.querier = querier
    
    self.startQuery(withQueryBehavior: queryBehavior)
    
    self.queryInvalidateListener(forIdentifier: queryIdentifier)
      .sink { [weak self] (invalidationRequestContext: VMQueryInvalidater<RequestContext>.InvalidationRequestContext) in
        switch invalidationRequestContext {
          case .last:
            if let requestContext = self?.lastRequestContext {
              self?.requery(forRequestContext: requestContext)
            }
          case .new(let requestContext):
            self?.requery(forRequestContext: requestContext)
        }
      }
      .store(in: &self.cancellables)
    
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
  
  private func startQuery(withQueryBehavior queryBehavior: QueryBehavior) {
    switch queryBehavior {
      case .startWhenRequery:
        break
      case .startImmediately(let requestContext):
        self.requery(forRequestContext: requestContext)
    }
  }
  
  private func isCacheValueValid(forKey key: AtsaniKey) -> Bool {
    return self.cache.isCacheValueValid(forKey: key, validDate: Date(), invalidationPolicy: self.cacheConfiguration.invalidationPolicy)
  }
  
  private func getCacheIfPossibly(forKey key: AtsaniKey) -> Response? {
    return self.isCacheValueValid(forKey: key) ? self.cache.fetchCache(forKey: key) : nil
  }
  
  private func performQuery(forRequestContext requestContext: RequestContext) {
    let cacheKey = self.cacheKeyHandler(self.queryIdentifier, requestContext)
    let cachedResponse = self.getCacheIfPossibly(forKey: cacheKey)
    
    switch self.cacheConfiguration.usagePolicy {
      case .useDontLoad where cachedResponse != nil:
        fallthrough
      case .useThenLoad where cachedResponse != nil:
        self.state = .success(cachedResponse!)
      default:
        break
    }
    
    // 如果 cacheConfiguration usagePolicy 为 useDontLoad, 则不应该触发请求
    guard self.cacheConfiguration.usagePolicy != .useDontLoad else {
      return
    }
    
    // 如果 cacheConfiguration usagePolicy 为 useThenLoad 时, 若 state 状态为 .success(Response)
    // 则仅将数据写入 cache, 不触发 state 更改
    // 若 state 状态为 .loading 或 .idle 则将数据写入 cache, 同时触发 state 更改
    self.querier(requestContext)
      .sink { [weak self] (completion) in
        switch (completion, self?.cacheConfiguration.usagePolicy) {
          case (.failure, .useWhenLoadFails) where cachedResponse != nil:
            self?.state = .success(cachedResponse!)
          case (.failure(let error), _):
            self?.state = .failure(error)
          default:
            break
        }
      } receiveValue: { [weak self] (response) in
        // 缓存数据
        self?.cache.cache(forKey: cacheKey, value: response, cacheDate: Date())
        
        switch self?.state {
          case .loading:
            self?.state = .success(response)
          default:
            break
        }
      }
      .store(in: &self.cancellables)
  }
}

#endif
