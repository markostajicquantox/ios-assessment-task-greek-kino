//
//  ResponseModels.swift
//  GreekKino
//
//

import Foundation

struct AddOn: Codable {
    let amount: Double
    let gameType: String
}

struct PricePoint: Codable {
    let addOn: [AddOn]
    let amount: Double
}

struct WinningNumbers: Codable {
    let list: [Int]
    let bonus: [Int]
}

struct PrizeCategory: Codable {
    let id: Int
    let divident: Double
    let winners: Int
    let distributed: Double
    let jackpot: Double
    let fixed: Double
    let categoryType: Int
    let gameType: String
}

struct PreviousRoundsResponse: Codable {
    let content: [GreekKinoRound]
}

struct GreekKinoRound: Codable, Hashable, Equatable {
    let gameId: Int
    let drawId: Int
    let drawTime: TimeInterval
    let status: String
    let drawBreak: Int
    let visualDraw: Int
    let pricePoints: PricePoint
    let prizeCategories: [PrizeCategory]
    let winningNumbers: WinningNumbers?
    
    static func == (lhs: GreekKinoRound, rhs: GreekKinoRound) -> Bool {
        lhs.drawId == rhs.drawId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(drawId)
    }
}
