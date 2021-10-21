//
//  AtsaniKey.swift
//  Atsani
//
//  Created by max on 2021/10/21.
//

#if canImport(Foundation)

import Foundation

public struct AtsaniKey: Hashable, AtsaniKeyProtocol {
  
  public let keyValue: String
  
  public init(value: String) {
    self.keyValue = value
  }
}

#endif
