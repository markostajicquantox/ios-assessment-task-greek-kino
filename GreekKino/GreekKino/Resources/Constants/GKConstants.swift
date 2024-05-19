//
//  GKConstants.swift
//  GreekKino
//
//

import Foundation

struct GKConstants {
    static let drawLink = "https://mozzartbet.com/sr/lotto-animation/26#"
    static let possibleNumbers = Array(1...80)
    static let possibleDeposits = [50, 100, 150, 200, 500, 1000, 2000, 5000]
    static let manualSelectionMaximum = 15
    static let randomSelectionMaximum = 8
    static let depositCurrency = "RSD"
    static let odds: [Odd] = [Odd(number: 1, odd: 3.75),
                              Odd(number: 2, odd: 14.0),
                              Odd(number: 3, odd: 65.0),
                              Odd(number: 4, odd: 275.0),
                              Odd(number: 5, odd: 1350.0),
                              Odd(number: 6, odd: 6500),
                              Odd(number: 7, odd: 25000),
                              Odd(number: 8, odd: 125000)]
}

struct Odd {
    let number: Int
    let odd: Double
}
