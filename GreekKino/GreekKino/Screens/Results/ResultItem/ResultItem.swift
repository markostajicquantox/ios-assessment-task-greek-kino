//
//  ResultItem.swift
//  GreekKino
//
//

import Foundation

struct ResultItem: Hashable, Equatable {
    let id: Int
    let startTime: String
    let winningNumbers: [Int]

    static func == (lhs: ResultItem, rhs: ResultItem) -> Bool {
        lhs.id == rhs.id && lhs.winningNumbers == rhs.winningNumbers
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(winningNumbers)
    }
}
