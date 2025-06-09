import SwiftUI

// MARK: - Custom Tab Section Options
enum CustomTabBarSection: Int, CaseIterable {
    case balance = 0
    case expenses = 1

    /// Display Properties
    var iconName: String {
        switch self {
        case .balance:
            return "dollarsign.circle"
        case .expenses:
            return "list.bullet"
        }
    }
    var title: AttributedString {
        switch self {
        case .balance:
            let firstString: String = "Remaining".uppercased()
            let secondString: String = "Balance".uppercased()

            var attributedString = AttributedString( ("\(firstString) \(secondString)") )

            if let helloRange = attributedString.range(of: firstString) {
                attributedString[helloRange].foregroundColor = .customWhiteSand.opacity(Constraint.Opacity.high)
                attributedString[helloRange].font = TextFonts.titleSmall.font
            }

            if let worldRange = attributedString.range(of: secondString) {
                attributedString[worldRange].foregroundColor = .customWhiteSand
                attributedString[worldRange].font = TextFonts.titleSmallBold.font
            }
            return attributedString

        case .expenses:
            let string: String = "Expenses".uppercased()

            var attributedString = AttributedString( string )
            attributedString.foregroundColor = .customWhiteSand
            attributedString.font = TextFonts.titleSmallBold.font
            return attributedString
        }
    }
}
