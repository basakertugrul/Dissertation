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
           return LegalSection.terms.rawValue
       case .privacy:
           return LegalSection.privacy.rawValue
       case .about:
           return LegalSection.about.rawValue
       }
   }
    
    private func createTitle(_ text: String) -> AttributedString {
        var title = AttributedString(text)
        title.foregroundColor = .customRichBlack
        title.font = TextFonts.titleSmallBold.font
        return title
    }
}
