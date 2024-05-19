//
//  Int+Extension.swift
//  GreekKino
//
//

import Foundation

extension Int {
    func toMinuteSecondString() -> String {
        let totalSeconds = self
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%2d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%2d:%02d", minutes, seconds)
        }
    }
}
