//
//  VMQueryState+Tests.swift
//  AtsaniTests
//
//  Created by max on 2021/10/21.
//

#if canImport(Foundation) && canImport(Atsani)

import Foundation
import Atsani

extension VMQueryState: Equatable where Response: Equatable {
  
  public static func == (lhs: VMQueryState<Response>, rhs: VMQueryState<Response>) -> Bool {
    switch (lhs, rhs) {
      case (.idle, .idle), (.loading, .loading):
        return true
      case (.success(let lhsResponse), .success(let rhsResponse)):
        return lhsResponse == rhsResponse
      case (.failure(let lhsError), .failure(let rhsError)) where lhsError is AtsaniTestError && rhsError is AtsaniTestError:
        return  (lhsError as! AtsaniTestError) == (rhsError as! AtsaniTestError)
      default:
        return false
    }
  }
}

#endif
