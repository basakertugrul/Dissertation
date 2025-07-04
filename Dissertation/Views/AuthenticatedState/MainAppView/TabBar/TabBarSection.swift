import SwiftUI

// MARK: - Custom Tab Section Options
enum TabBarSection: Int, CaseIterable {
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
            let firstString: String = NSLocalizedString("remaining", comment: "")
            let secondString: String = NSLocalizedString("budget", comment: "")

            var attributedString = AttributedString( ("\(firstString) \(secondString)") )

            if let helloRange = attributedString.range(of: firstString) {
                attributedString[helloRange].foregroundColor = .customRichBlack.opacity(Constraint.Opacity.high)
                attributedString[helloRange].font = TextFonts.titleSmall.font
            }

            if let worldRange = attributedString.range(of: secondString) {
                attributedString[worldRange].foregroundColor = .customRichBlack
                attributedString[worldRange].font = TextFonts.titleSmallBold.font
            }
            return attributedString

        case .expenses:
            let string: String = NSLocalizedString("expenses", comment: "")

            var attributedString = AttributedString( string )
            attributedString.foregroundColor = .customRichBlack
            attributedString.font = TextFonts.titleSmallBold.font
            return attributedString
        }
    }
}
