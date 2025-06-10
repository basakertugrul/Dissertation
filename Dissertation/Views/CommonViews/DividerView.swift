import SwiftUI

// MARK: - Divider View
struct DividerView: View {
    var willAddSpacing: Bool = true

    var body: some View {
        Rectangle()
            .fill(.customRichBlack.opacity(Constraint.Opacity.medium))
            .frame(height: Constraint.smallSize)
            .padding(
                .vertical,
                willAddSpacing ? Constraint.padding : .zero
            )
    }
}

struct MatchingBudgetHighlight: View {
    var body: some View {
        VStack(spacing: 20) {
            // Header - matching the original style
            Text("REMAINING BUDGET")
                .font(.title2)
                .fontWeight(.light)
                .foregroundColor(.primary)
            
            // Highlight card - styled like other cards but with green background
            VStack(spacing: 12) {
                Text("AVAILABLE")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(1)
                
                Text("£20")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text("CRUSHING IT!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.42, green: 0.75, blue: 0.41), // Matching your green
                        Color(red: 0.35, green: 0.65, blue: 0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20)) // Matching corner radius
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2) // Subtle shadow like other cards
            
            // Tab selector - exactly like your existing one
            HStack(spacing: 8) {
                TabButtonn(title: "DAILY", isSelected: false, color: Color(UIColor.systemGray))
                TabButtonn(title: "WEEKLY", isSelected: true, color: Color(red: 0.6, green: 0.3, blue: 0.3)) // Matching your red
                TabButtonn(title: "MONTHLY", isSelected: false, color: Color(UIColor.systemGray))
                TabButtonn(title: "YEARLY", isSelected: false, color: Color(UIColor.systemGray))
            }
            
            // Budget card - exactly matching your style
            VStack(alignment: .leading, spacing: 16) {
                Text("Budget")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Chart exactly like yours
                HStack(alignment: .bottom, spacing: 20) {
                    VStack(spacing: 8) {
                        Text("£350")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Rectangle()
                            .fill(Color(red: 0.42, green: 0.75, blue: 0.41)) // Matching green
                            .frame(width: 80, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text("Limit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("£390")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Rectangle()
                            .fill(Color(red: 0.6, green: 0.3, blue: 0.3)) // Matching your red
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            // Bottom cards - exactly matching your style
            HStack(spacing: 12) {
                BottomCard(
                    title: "DAILY LIMIT",
                    value: "£50",
                    hasEditIcon: true,
                    backgroundColor: Color(UIColor.systemGray)
                )
                
                BottomCard(
                    title: "DAYS TRACKED",
                    value: "9",
                    subtitle: "since May 2",
                    hasEditIcon: false,
                    backgroundColor: Color(UIColor.systemGray)
                )
            }
            
            // Total expenses card - exactly matching
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(red: 0.6, green: 0.3, blue: 0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "target")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        )
                    
                    Text("TOTAL EXPENSES")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(0.5)
                }
                
                Spacer()
                
                Text("£430")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(Color(UIColor.systemGray))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
    }
}

struct TabButtonn: View {
    let title: String
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct BottomCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let hasEditIcon: Bool
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(0.5)
                
                Spacer()
                
                if hasEditIcon {
                    Circle()
                        .fill(Color(red: 0.6, green: 0.3, blue: 0.3))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    MatchingBudgetHighlight()
        .background(Color(.systemGroupedBackground))
}
