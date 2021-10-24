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
    let pageable = ["limit", "offset"]
    let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
    
    let pageableUrlComponents = urlComponents.flatMap({ $0.queryItems?.map({ $0.name }).filter({ pageable.contains($0) }) }) ?? []
    
    return Set(pageableUrlComponents) == Set(pageable)
  }
}

#endif
