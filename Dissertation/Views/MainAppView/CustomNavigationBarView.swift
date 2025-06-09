import SwiftUI

/// Custom Navigation Bar View
struct CustomNavigationBarView: View {
    @Binding var selectedTab: CustomTabBarSection

    var body: some View {
        CustomNavigationBarTitleView(title: selectedTab.title)
            .animation(.easeInOut, value: selectedTab)
    }
}

/// Custom Navigation Bar Ttitle View
struct CustomNavigationBarTitleView: View {
    let title: AttributedString

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constraint.padding)
            .padding(.top, Constraint.extremePadding)
            .padding(.bottom, Constraint.largePadding)
    }
}
