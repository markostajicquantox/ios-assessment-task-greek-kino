//
//  Localized.swift
//  GreekKino
//
//

import Foundation

enum Localized {
    enum PickerView {
        static let done = String(localized: "Done")
        static let cancel = String(localized: "Cancel")
    }
    
    enum TabBar {
        static let nextRounds = String(localized: "NextRounds")
        static let draw = String(localized: "Draw")
        static let results = String(localized: "Results")
    }
    
    enum NextRounds {
        static let startingSoon = String(localized: "StartingSoon")
        static let round = String(localized: "Round")
        static let starts = String(localized: "Starts")
        static let noTimeLeft = String(localized: "NoTimeLeft")
    }
    
    enum NumberSelection {
        static let selectedNumbers = String(localized: "Selected numbers:")
        static let prizeSystem = String(localized: "PrizeSystem")
        static let oddSystem = String(localized: "OddSystem")
        static let odd = String(localized: "Odd")
        static let potentialPrize = String(localized: "PotentialPrize")
        static let remainingTimeNoTimeLeft = String(localized: "RemainingTimeNoTimeLeft")
        static let remainingTime = String(localized: "RemainingTime")
        static let randomSelection = String(localized: "RandomSelection")
        static let deposit = String(localized: "Deposit")
        static let random = String(localized: "Random")
        static let number = String(localized: "Number")
        static let numbers = String(localized: "Numbers")
        static let id = String(localized: "ID")
        static let checkout = String(localized: "Checkout")
        static let clear = String(localized: "Clear")
    }
    
    enum Results {
        static let time = String(localized: "Time")
        static let round = String(localized: "Round")
    }
    
    enum General {
        static let error = String(localized: "Error")
        static let ok = String(localized: "Ok")
    }
}
