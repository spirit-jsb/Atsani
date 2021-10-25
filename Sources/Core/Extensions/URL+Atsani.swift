//
//  URL+Atsani.swift
//  Atsani
//
//  Created by Max on 2021/10/24.
//

#if canImport(Foundation)

import Foundation

extension URL {
  
  public var isPageable: Bool {        
    return URLComponents(url: self, resolvingAgainstBaseURL: true).flatMap({ $0.queryItems?.map({ $0.name }) })?.contains("limit") ?? false
  }
  
  public var limit: Int? {
    return URLComponents(url: self, resolvingAgainstBaseURL: true).flatMap({ $0.queryItems?.filter({ $0.name == "limit" }) })?.first?.value.flatMap({ Int($0) })
  }
  
  public var offset: Int? {
    return URLComponents(url: self, resolvingAgainstBaseURL: true).flatMap({ $0.queryItems?.filter({ $0.name == "offset" }) })?.first?.value.flatMap({ Int($0) })
  }
}

#endif
