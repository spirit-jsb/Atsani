//
//  VMQueryState.swift
//  Atsani
//
//  Created by max on 2021/10/18.
//

#if canImport(Foundation)

import Foundation

public enum VMQueryState<Response> {
  case idle
  case loading
  case loadMore
  case success(Response)
  case failure(Error)
  
  public func value() throws -> Response? {
    switch self {
      case .success(let response):
        return response
      case .failure(let error):
        throw error
      default:
        return nil
    }
  }
}

#endif
