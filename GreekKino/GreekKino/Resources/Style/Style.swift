//
//  Style.swift
//  GreekKino
//
//

import UIKit

extension UIFont {
    static var semibold = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static var regular = UIFont.systemFont(ofSize: 17, weight: .regular)
    static var light = UIFont.systemFont(ofSize: 17, weight: .light)
}

struct Style {
    var font: UIFont
    var textColor: UIColor
}

protocol StyleProtocol {
    var style: Style? { get set }
}

extension UILabel: StyleProtocol {
    var style: Style? {
        get {
            return Style(font: self.font, textColor: self.textColor)
        }
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            self.textColor = newValue.textColor
            self.font = newValue.font
        }
    }
}

extension Style {
    static var numberSelection: Style { return Style(font: .semibold, textColor: .text) }
    static var primaryNavigation: Style { return Style(font: .regular, textColor: .white) }
    static var secondaryNavigation: Style { return Style(font: .light, textColor: .white) }
    static var primaryDark: Style { return Style(font: .regular, textColor: .text) }
    static var secondaryDark: Style { return Style(font: .light, textColor: .text) }
    static var primaryGray: Style { return Style(font: .regular, textColor: .secondaryText) }
    static var secondaryGray: Style { return Style(font: .light, textColor: .secondaryText) }
    static var primaryDisabled: Style { return Style(font: .regular, textColor: .secondaryText) }
    static var secondaryDisabled: Style { return Style(font: .light, textColor: .secondaryText) }
    static var primaryDestructive: Style { return Style(font: .regular, textColor: .destructive) }
    static var secondaryDestructive: Style { return Style(font: .light, textColor: .destructive) }
}
