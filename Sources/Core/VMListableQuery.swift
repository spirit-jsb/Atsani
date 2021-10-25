//
//  VMListableQuery.swift
//  Atsani
//
//  Created by Max on 2021/10/25.
//

#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public final class VMListableQuery<RequestContext: Collection, Response: Collection>: ObservableObject, VMQueryProtocol, VMQueryInvalidateListener where Response.Element: Codable {
  
  public typealias CacheKeyHandler = (AtsaniKey, RequestContext.Element) -> AtsaniKey
  public typealias CacheHandler = (RequestContext.Element, Response) -> Response.Element?
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
  
  private let queryIdentifier: AtsaniKey
  
  private let cacheKeyHandler: CacheKeyHandler
  private let cacheHandler: CacheHandler
  private let cache: VMCacheProtocol
  private let cacheConfiguration: VMCacheConfiguration
  
  private let querier: Querier
  
  private var lastRequestContext: RequestContext?
  
  private var cancellables = Set<AnyCancellable>()
  
  public init(
    queryIdentifier: AtsaniKey,
    cacheKeyHandler: @escaping CacheKeyHandler,
    cacheHandler: @escaping CacheHandler,
    cache: VMCacheProtocol = VMUserDefaultsCache.shared,
    cacheConfiguration: VMCacheConfiguration = VMCacheConfiguration.`default`,
    queryBehavior: QueryBehavior = .startWhenRequery,
    querier: @escaping Querier
  ) {
    self.queryIdentifier = queryIdentifier
    
    self.cacheKeyHandler = cacheKeyHandler
    self.cacheHandler = cacheHandler
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
  
  private func getCacheIfPossibly(forKey key: AtsaniKey) -> Response.Element? {
    return self.isCacheValueValid(forKey: key) ? self.cache.fetchCache(forKey: key) : nil
  }
  
  private func performQuery(forRequestContext requestContext: RequestContext) {
    let cacheKeys = requestContext.map { self.cacheKeyHandler(self.queryIdentifier, $0) }
    let cachedResponses = cacheKeys.compactMap { self.getCacheIfPossibly(forKey: $0) } as! Response
    
    // 当且仅当数据数量一致时缓存为有效缓存
    switch self.cacheConfiguration.usagePolicy {
      case .useDontLoad where !cachedResponses.isEmpty && cachedResponses.count == requestContext.count:
        fallthrough
      case .useThenLoad where !cachedResponses.isEmpty && cachedResponses.count == requestContext.count:
        self.state = .success(cachedResponses)
      default:
        break
    }
    
    // 如果 cacheConfiguration usagePolicy 为 useDontLoad, 则不应该触发请求
    guard self.cacheConfiguration.usagePolicy != .useDontLoad else {
      return
    }
    
    // 如果 cacheConfiguration usagePolicy 为 useThenLoad 时, 若 state 状态为 .success(Response)
    // 则仅将数据写入 cache, 不触发 stage 更改
    // 若 state 状态为 .loading 或 .idle 则将数据写入 cache, 同时触发 stage 更改
    self.querier(requestContext)
      .sink { (completion) in
        switch (completion, self.cacheConfiguration.usagePolicy) {
          case (.failure, .useWhenLoadFails) where !cachedResponses.isEmpty && cachedResponses.count == requestContext.count:
            self.state = .success(cachedResponses)
          case (.failure(let error), _):
            self.state = .failure(error)
          default:
            break
        }
      } receiveValue: { (responses) in
        // 缓存数据
        cacheKeys.enumerated().forEach { (index, cacheKey) in
          let requestContextIndex = requestContext.index(requestContext.startIndex, offsetBy: index)
          
          guard let needCachedResponse = self.cacheHandler(requestContext[requestContextIndex], responses) else {
            return
          }
          
          self.cache.cache(forKey: cacheKey, value: needCachedResponse, cacheDate: Date())
        }
        
        switch (self.cacheConfiguration.usagePolicy, self.state) {
          case (.useThenLoad, .success):
            break
          default:
            self.state = .success(responses)
        }
      }
      .store(in: &self.cancellables)
  }
}

#endif
