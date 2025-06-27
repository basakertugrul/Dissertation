import SwiftUI

/// Custom Navigation Bar View
struct CustomNavigationBarView: View {
    @Binding var selectedTab: CustomTabBarSection
    @Binding var isProfileScreenOpen: Bool

    var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            CustomNavigationBarTitleView(title: selectedTab.title)
                .animation(.easeInOut, value: selectedTab)
            Button {
                HapticManager.shared.trigger(.navigation)
                withAnimation(.linear) {
                    isProfileScreenOpen = true
                }
            } label: {
                Image(systemName: "person.fill")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: Constraint.mediumIconSize, height: Constraint.mediumIconSize)
                    .foregroundColor(.customRichBlack)
                    .padding([.top, .horizontal], Constraint.padding)
                    .padding(.bottom, Constraint.largePadding)
            }
        }
    }
}

/// Custom Navigation Bar Title View
struct CustomNavigationBarTitleView: View {
    let title: AttributedString

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .horizontal], Constraint.padding)
            .padding(.bottom, Constraint.largePadding)
    }
}
