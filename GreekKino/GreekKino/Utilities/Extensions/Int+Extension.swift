//
//  Int+Extension.swift
//  GreekKino
//
//

import Foundation

extension Int {
    func toMinuteSecondString() -> String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
