import SwiftUI

extension View {
    /// Show Legal Information Alert
    func showLegalInformationAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                LegalInformationOverlay(isShowing: isPresented)
                    .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
}

struct LegalInformationOverlay: View {
   @Binding var isShowing: Bool
   @State private var selectedSection: LegalSection? = nil
   
   enum LegalSection: String, CaseIterable {
       case terms = "Terms of Service"
       case privacy = "Privacy Policy"
       case about = "About FundBud"
   }
   
   var body: some View {
       ZStack {
           Color.black.opacity(Constraint.Opacity.medium).ignoresSafeArea()
           Rectangle()
               .fill(.ultraThinMaterial.opacity(Constraint.Opacity.medium))
               .ignoresSafeArea()
               .onTapGesture {  isShowing = false }

           VStack(spacing: .zero) {
               if let selectedSection = selectedSection {
                   // Document Header with Back Button
                   HStack(alignment: .lastTextBaseline) {
                       Button {
                           withAnimation {
                               self.selectedSection = nil
                           }
                       } label: {
                           Image(systemName: "chevron.left")
                               .renderingMode(.template)
                               .bold()
                               .foregroundColor(.customBurgundy)
                       }
                       
                       Spacer()
                       
                       CustomNavigationBarTitleView(title: createTitle(selectedSection.rawValue))
                       
                       Spacer()
                       
                       Button {
                           isShowing = false
                       } label: {
                           Image(systemName: "xmark.circle.fill")
                               .foregroundColor(.customRichBlack.opacity(Constraint.Opacity.high))
                               .font(.title2)
                       }
                   }
                   .padding(Constraint.padding)
                   .background(Color.customWhiteSand)
                   
                   // Document Content
                   ScrollView {
                       CustomTextView(
                           getContent(for: selectedSection),
                           font: .labelLarge,
                           color: .customRichBlack
                       )
                       .padding(Constraint.padding)
                   }
                   .background(Color.customWhiteSand)
                   
               } else {
                   // Main Header
                   HStack(alignment: .lastTextBaseline) {
                       CustomNavigationBarTitleView(title: createTitle("Legal Information"))
                       Spacer()
                       Button {
                           isShowing = false
                       } label: {
                           Image(systemName: "xmark.circle.fill")
                               .foregroundColor(.customRichBlack.opacity(Constraint.Opacity.medium))
                               .font(.title2)
                       }
                   }
                   .padding(Constraint.padding)
                   .background(Color.customWhiteSand)
                   
                   // Menu View
                   VStack(spacing: .zero) {
                       ForEach(LegalSection.allCases, id: \.self) { section in
                           Button {
                               withAnimation {
                                   selectedSection = section
                               }
                           } label: {
                               HStack(alignment: .bottom) {
                                   CustomTextView(
                                       section.rawValue,
                                       font: .bodySmall,
                                       color: .customRichBlack
                                   )
                                   Spacer()
                                   Image(systemName: "chevron.right")
                                       .foregroundColor(.customRichBlack.opacity(0.4))
                               }
                               .padding()
                               .background(Color.white)
                           }
                           
                           if section != LegalSection.allCases.last {
                               Divider()
                           }
                       }
                   }
               }
           }
           .background(Color.customWhiteSand)
           .cornerRadius(Constraint.cornerRadius)
           .padding(Constraint.regularPadding)
           .shadow(
            color: .customRichBlack.opacity(Constraint.Opacity.medium),
            radius: Constraint.shadowRadius
           )
       }
   }
   
   private func getContent(for section: LegalSection) -> String {
       switch section {
       case .terms:
           return LegalTexts.termsOfService
       case .privacy:
           return LegalTexts.privacyPolicy
       case .about:
           return LegalTexts.aboutApp
       }
   }
    
    private func createTitle(_ text: String) -> AttributedString {
        var title = AttributedString(text)
        title.foregroundColor = .customRichBlack
        title.font = TextFonts.titleSmallBold.font
        return title
    }
}

struct LegalTexts {
   static let termsOfService = """
   TERMS OF SERVICE
   
   Last updated: June 2025
   
   1. ACCEPTANCE OF TERMS
   By downloading and using FundBud, you agree to these terms.
   
   2. DESCRIPTION OF SERVICE
   FundBud is a personal expense tracking app that helps you monitor your daily spending.
   
   3. USER RESPONSIBILITIES
   • Provide accurate expense information
   • Use the app responsibly
   • Keep your device secure
   
   4. DATA STORAGE
   All your data is stored locally on your device. We don't access or share your financial information.
   
   5. LIMITATION OF LIABILITY
   FundBud is provided "as is" without warranties.
   """
   
   static let privacyPolicy = """
   PRIVACY POLICY
   
   Last updated: June 2025
   
   YOUR PRIVACY MATTERS
   We respect your privacy and are committed to protecting your personal information.
   
   INFORMATION WE COLLECT
   • App usage data (stored locally)
   • No personal financial data is transmitted
   • No third-party tracking
   
   DATA STORAGE
   • All expense data stays on your device
   • We don't have access to your information
   • Data is secured with Face ID/Touch ID
   
   CONTACT US
   If you have questions about this privacy policy, contact us at fundBud2025@gmail.com
   """
   
   static let aboutApp = """
   ABOUT FUNDBUD
   
   Version: 1.0
   
   FundBud helps you track your daily expenses and stay within your budget.
   
   FEATURES
   • Daily expense tracking
   • Budget monitoring
   • Spending insights
   • Secure local storage
   
   DEVELOPMENT
   Made with ❤️ to help you manage your finances better.
   
   © 2025 FundBud. All rights reserved.
   """
}
