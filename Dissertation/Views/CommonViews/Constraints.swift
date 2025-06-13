import SwiftUI

// MARK: - Default UI Constraints
struct Constraint {
    static let tinyPadding: CGFloat = 4
    static let smallPadding: CGFloat = 8
    static let regularPadding: CGFloat = 12
    static let padding: CGFloat = 16
    static let largePadding: CGFloat = 32
    static let extremePadding: CGFloat = 48

    static let smallSize: CGFloat = 1
    static let mediumSize: CGFloat = 4
    static let extremeSize: CGFloat = 60

    static let smallIconSize: CGFloat = 16
    static let regularIconSize: CGFloat = 22
    static let mediumIconSize: CGFloat = 28
    static let largeIconSize: CGFloat = 36
    static let extremeIconSize: CGFloat = 52

    static let smallCornerRadius: CGFloat = 8
    static let regularCornerRadius: CGFloat = 12
    static let cornerRadius: CGFloat = 16
    
    static let shadowRadius: CGFloat = 4
    static let largeShadowRadius: CGFloat = 10
    
    static let mainButtonOffset: CGFloat = -20
    
    static let tinyLineLenght: CGFloat = 1
    static let smallLineLenght: CGFloat = 2
    static let mediumLineLenght: CGFloat = 4
    static let largeLineLenght: CGFloat = 8
    
    static let regularImageSize: CGFloat = 240
    static let largeImageSize: CGFloat = 320
    static let extremeImageSize: CGFloat = 480
    
    static let blurRadius: CGFloat = 10
    static let smallBlurRadius: CGFloat = 7
    
    static let animationDuration: Double = 0.75
    static let animationDurationShort: Double = 0.3

    struct Opacity {
        static let hidden: Double = 0
        static let tiny: Double = 0.02
        static let low: Double = 0.2
        static let medium: Double = 0.5
        static let high: Double = 0.7
        static let visible: Double = 1
    }
    
    struct LayerWeight {
        static let light: CGFloat = 0.2
        static let medium: CGFloat = 0.5
        static let heavy: CGFloat = 0.7
    }
}
