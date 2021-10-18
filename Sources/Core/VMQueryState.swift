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
  case success(Response)
  case failure(Error)
  
  public var value: Response? {
    switch self {
      case .success(let response):
        return response
      default:
        return nil
    }
  }
}

#endif
