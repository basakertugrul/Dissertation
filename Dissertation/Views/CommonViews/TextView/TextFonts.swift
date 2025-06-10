import SwiftUI

enum TextFonts {
    /// Title styles
    case titleLarge
    case titleMedium
    case titleMediumBold
    case titleSmall
    case titleSmallBold

    /// Body text styles
    case bodyLarge
    case bodyLargeBold
    case bodySmall
    case bodySmallBold

    /// Label styles
    case labelLarge
    case labelLargeBold
    case labelMedium
    case labelSmall
    case labelSmallBold

    /// Returns the appropriate font style for each case
    var font: Font {
        switch self {
            /// Title styles
        case .titleLarge:
            return .system(size: 54, weight: .light)
        case .titleMedium:
            return .system(size: 32, weight: .light)
        case .titleMediumBold:
            return .system(size: 32, weight: .semibold)
        case .titleSmall:
            return .system(size: 24, weight: .light)
        case .titleSmallBold:
            return .system(size: 24, weight: .bold)

        case .bodyLargeBold:
            return .system(size: 20, weight: .bold)
        case .bodyLarge:
            return .system(size: 20, weight: .regular)
        case .bodySmall:
            return .system(size: 18, weight: .regular)
        case .bodySmallBold:
            return .system(size: 18, weight: .bold)

        case .labelLarge:
            return .system(size: 14, weight: .light)
        case .labelLargeBold:
            return .system(size: 14, weight: .bold)
        case .labelMedium:
            return .system(size: 12, weight: .light)
        case .labelSmall:
            return .system(size: 10, weight: .light)
        case .labelSmallBold:
            return .system(size: 10, weight: .semibold)
        }
    }

    /// Returns the appropriate tracking (letter spacing) for each case
    var tracking: CGFloat {
        switch self {
            /// Titles typically have tighter tracking
        case .titleLarge, .titleSmall, .titleSmallBold, .titleMedium, .titleMediumBold:
            return 0.5

            /// Body text with normal tracking
        case .bodyLarge, .bodySmall, .bodySmallBold, .bodyLargeBold:
            return 0

            /// Labels often have wider tracking, especially when uppercase
        case .labelLarge, .labelLargeBold:
            return 2.0
        case .labelMedium:
            return 1.5
        case .labelSmall, .labelSmallBold:
            return 1.2
        }
    }
}
