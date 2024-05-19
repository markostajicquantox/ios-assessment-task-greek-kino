//
//  NextRoundCellItem.swift
//  GreekKino
//
//

import Foundation

struct NextRoundCellItem: Hashable, Equatable {
    let id: Int
    let time: TimeInterval
    let startTime: String
    var remainingTime: Int
    
    static func == (lhs: NextRoundCellItem, rhs: NextRoundCellItem) -> Bool {
        lhs.id == rhs.id && lhs.remainingTime == rhs.remainingTime
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
