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
               .onTapGesture {
                   HapticManager.shared.trigger(.cancel)
                   isShowing = false
               }

           VStack(spacing: .zero) {
               if let selectedSection = selectedSection {
                   // Document Header with Back Button
                   HStack(alignment: .lastTextBaseline) {
                       Button {
                           HapticManager.shared.trigger(.navigation)
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
                           HapticManager.shared.trigger(.cancel)
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
                           color: .customRichBlack,
                           alignment: .leading
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
                           HapticManager.shared.trigger(.cancel)
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
                               HapticManager.shared.trigger(.navigation)
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
       .onAppear {
           HapticManager.shared.trigger(.notification)
       }
   }
   
    private func getContent(for section: LegalSection) -> String {
        switch section {
        case .terms:
            return """
            TERMS & CONDITIONS
            
            Last updated: \(getCurrentYear())
            
            WHAT IS THIS APP?
            This is a personal expense tracker that helps you manage your spending. By using this app, you agree to these terms.
            
            WHAT YOU CAN DO
            • Track your expenses and income
            • Set spending budgets
            • Take photos of receipts
            • Export your data anytime
            • Use all features for personal use
            
            WHAT YOU CAN'T DO
            • Share false information
            • Use the app for illegal activities
            • Try to break or hack the app
            • Sell or redistribute the app
            
            YOUR DATA
            • Everything stays on your device
            • We don't see or store your financial data
            • Camera is only used for receipts
            • You own and control all your information
            
            LEGAL SIDE
            • App provided "as is" - we can't guarantee it's perfect
            • Not financial advice - make your own money decisions
            • We're not responsible if you lose money
            • These terms can change (we'll let you know)
            
            📧 QUESTIONS?
            Contact us: fundBud2025@gmail.com
            
            Thanks for using our app responsibly! 🙏
            """

        case .privacy:
            return """
            PRIVACY POLICY
            
            Last updated: \(getCurrentYear())
            
            WE PROTECT YOUR PRIVACY
            Your financial data is personal. Here's exactly how we handle it.
            
            WHAT WE COLLECT
            On Your Device Only:
            • Your expense amounts and notes
            • Budget limits you set
            • Receipt photos you take
            • Categories you choose
            
            Anonymous Usage Data:
            • How often features are used
            • Crash reports (no personal data)
            • App performance metrics
            
            WHERE YOUR DATA LIVES
            • Everything stays on YOUR device
            • Nothing uploaded to our servers
            • No cloud storage of personal data
            • You delete it, it's gone forever
            
            CAMERA ACCESS
            • Only used when you scan receipts
            • Photos saved to your device only
            • You can delete photos anytime
            • We never access your photo library
            
            WHAT WE DON'T DO
            • Sell your data (never!)
            • Share with advertisers
            • Read your financial information
            • Track you across other apps
            
            KIDS
            This app isn't for children under 13.
            
            YOUR RIGHTS
            • See all your data (it's in the app!)
            • Export everything anytime
            • Delete all data by uninstalling
            • Ask us questions about privacy
            
            PRIVACY QUESTIONS?
            Contact us: fundBud2025@gmail
            
            Your trust means everything to us! 🔐
            """

        case .about:
            return """
            ABOUT FUNDBUD
            
            Version \(getAppVersion()) • Made with ❤️
            
            OUR MISSION
            Make expense tracking so simple, you'll actually do it every day.
            
            WHAT MAKES US SPECIAL
            
            Privacy First:
            • Everything stays on your device
            • No accounts or sign-ups needed
            • Your data belongs to you
            
            Lightning Fast:
            • Add expenses in seconds
            • Quick amounts: £1, £2, £5, £10
            • Home screen widget support
            • Instant receipt scanning
            
            Smart & Simple:
            • Beautiful, easy interface
            • Helpful spending insights
            • Budget tracking that works
            • Works offline always
            
            BUILT WITH
            • Swift & SwiftUI
            • Advanced haptic feedback
            • iOS 16+ optimized
            • Accessibility focused
            
            FOR EVERYONE
            • VoiceOver support
            • Dynamic text sizing
            • High contrast modes
            • Simple, clear navigation
            
            COMING SOON
            • Better Notifications
            • Apple Watch app
            • More currencies
            • Advanced reports
            • Even better widgets
            
            💌 GET IN TOUCH
            
            Love the app? Found a bug? Need help? Tell us!
            fundBud2025@gmail
            
            🏆 THANK YOU
            To everyone who uses this app - you're helping us build something amazing while keeping your privacy intact.
            
            📱 REQUIREMENTS
            • iPhone with iOS 16+
            • Works on all screen sizes
            • iPad compatible
            • Dark & Light mode
            
            © \(getCurrentYear()) FundBud
            Made in the UK 🇬🇧
            """
        }
    }

    // MARK: - Helper Functions
    private func getCurrentYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }

    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func createTitle(_ text: String) -> AttributedString {
        var title = AttributedString(text)
        title.foregroundColor = .customRichBlack
        title.font = TextFonts.titleSmallBold.font
        return title
    }
}
