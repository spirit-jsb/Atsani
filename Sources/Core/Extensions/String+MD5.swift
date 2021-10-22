//
//  String+MD5.swift
//  Atsani
//
//  Created by max on 2021/10/22.
//

#if canImport(Foundation) && canImport(CryptoKit)

import Foundation
import CryptoKit

extension String {
  
  func md5() -> String {
    return self.data(using: .utf8).flatMap { Insecure.MD5.hash(data: $0).makeIterator().compactMap { String(format: "%02x", $0) }.joined() } ?? self
  }
}

#endif
