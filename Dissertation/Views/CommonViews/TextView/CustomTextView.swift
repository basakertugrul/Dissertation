import SwiftUI

/// Custom text view that accepts a TextFonts parameter
struct CustomTextView: View {
    let text: String
    let font: TextFonts
    let color: Color
    let uppercase: Bool
    let isBold: Bool

    init(
        _ text: String,
        font: TextFonts,
        color: Color = .customWhiteSand,
        uppercase: Bool = false,
        isBold: Bool = false
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.uppercase = uppercase
        self.isBold = isBold
    }

    var body: some View {
        let displayText = uppercase ? text.uppercased() : text
        var newFont: Font {
            if isBold { return font.font.weight(.semibold) }
            return font.font
        }

            Text(displayText)
                .font(newFont)
                .bold()
                .tracking(font.tracking)
                .foregroundColor(color)
    }

    /// Static method to create a currency-formatted text view
    static func currency(
        _ value: Double,
        font: TextFonts,
        currencySymbol: String = "£",
        color: Color
    ) -> some View {
        let formattedValue = value.formatted()

        return HStack(spacing: .zero) {
            Text(currencySymbol)
                .font(font.font.weight(.semibold))
                .tracking(font.tracking)
                .baselineOffset(font == .titleLarge ? 5 : 0)
            
            Text(formattedValue)
                .font(font.font.weight(.semibold))
                .bold()
                .tracking(font.tracking)
        }
        .foregroundColor(color)
    }
}
