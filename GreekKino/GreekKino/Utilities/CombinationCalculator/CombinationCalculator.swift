//
//  CombinationCalculator.swift
//  GreekKino
//
//

import Foundation

struct CombinationCalculator {
    
    var n: Int
    var k: Int
    
    init(n: Int, k: Int) {
        self.n = n
        self.k = k
    }
    
    private func factorial(_ n: Int) -> Double {
        return (1...n).map(Double.init).reduce(1.0, *)
    }

    private func combinations(n: Int, k: Int) -> Double {
        return factorial(n) / (factorial(k) * factorial(n - k))
    }
    
    func combinations() -> Double {
        return combinations(n: self.n, k: self.k)
    }
}
