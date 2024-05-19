//
//  NumberSelectionItem.swift
//  GreekKino
//
//

import Foundation

struct NumberSelectionItem: Hashable, Equatable {
    let number: Int
    var isSelected: Bool
    var onSelect: NoArgsClosure?
    
    static func == (lhs: NumberSelectionItem, rhs: NumberSelectionItem) -> Bool {
        lhs.number == rhs.number && lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
        hasher.combine(isSelected)
    }
}
