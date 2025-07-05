import SwiftUI

/// Custom text view that accepts a TextFonts parameter
struct CustomTextView: View {
    let text: String
    let font: TextFonts
    let color: Color
    let uppercase: Bool
    let isBold: Bool
    let alignment: TextAlignment

    init(
        _ text: String,
        font: TextFonts,
        color: Color = .customWhiteSand,
        uppercase: Bool = false,
        isBold: Bool = false,
        alignment: TextAlignment = .center
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.uppercase = uppercase
        self.isBold = isBold
        self.alignment = alignment
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
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(alignment)
                .foregroundColor(color)
    }

    /// Static method to create a currency-formatted text view
    static func currency(
        _ value: Double,
        font: TextFonts,
        color: Color
    ) -> some View {
        let formattedValue = value.formatted()

        return HStack(alignment: .bottom, spacing: .zero) {
            Text(getCurrencySymbol())
                .font(font.font)
                .tracking(font.tracking)

            Text(formattedValue)
                .font(font.font)
                .tracking(font.tracking)
        }
        .foregroundColor(color)
    }
}
