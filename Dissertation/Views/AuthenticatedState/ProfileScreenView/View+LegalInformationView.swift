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
       case terms = "terms"
       case privacy = "privacy"
       case about = "about"
       
       var displayName: String {
           switch self {
           case .terms: return NSLocalizedString("terms_of_service", comment: "")
           case .privacy: return NSLocalizedString("privacy_policy", comment: "")
           case .about: return NSLocalizedString("about_fundbud", comment: "")
           }
       }
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
                       
                       CustomNavigationBarTitleView(title: createTitle(selectedSection.displayName))
                       
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
                       CustomNavigationBarTitleView(title: createTitle(NSLocalizedString("legal_information", comment: "")))
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
                                       section.displayName,
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
            \(NSLocalizedString("terms_conditions_title", comment: ""))
            
            \(NSLocalizedString("last_updated", comment: "")) \(getCurrentYear())
            
            \(NSLocalizedString("what_is_this_app", comment: ""))
            \(NSLocalizedString("terms_app_description", comment: ""))
            
            \(NSLocalizedString("what_you_can_do", comment: ""))
            \(NSLocalizedString("terms_can_do_1", comment: ""))
            \(NSLocalizedString("terms_can_do_2", comment: ""))
            \(NSLocalizedString("terms_can_do_3", comment: ""))
            \(NSLocalizedString("terms_can_do_4", comment: ""))
            \(NSLocalizedString("terms_can_do_5", comment: ""))
            
            \(NSLocalizedString("what_you_cannot_do", comment: ""))
            \(NSLocalizedString("terms_cannot_do_1", comment: ""))
            \(NSLocalizedString("terms_cannot_do_2", comment: ""))
            \(NSLocalizedString("terms_cannot_do_3", comment: ""))
            \(NSLocalizedString("terms_cannot_do_4", comment: ""))
            
            \(NSLocalizedString("your_data_terms", comment: ""))
            \(NSLocalizedString("terms_data_1", comment: ""))
            \(NSLocalizedString("terms_data_2", comment: ""))
            \(NSLocalizedString("terms_data_3", comment: ""))
            \(NSLocalizedString("terms_data_4", comment: ""))
            
            \(NSLocalizedString("legal_side", comment: ""))
            \(NSLocalizedString("terms_legal_1", comment: ""))
            \(NSLocalizedString("terms_legal_2", comment: ""))
            \(NSLocalizedString("terms_legal_3", comment: ""))
            \(NSLocalizedString("terms_legal_4", comment: ""))
            
            \(NSLocalizedString("terms_questions", comment: ""))
            \(NSLocalizedString("contact_us", comment: ""))
            
            \(NSLocalizedString("terms_thanks", comment: ""))
            """

        case .privacy:
            return """
            \(NSLocalizedString("privacy_policy_title", comment: ""))
            
            \(NSLocalizedString("last_updated", comment: "")) \(getCurrentYear())
            
            \(NSLocalizedString("privacy_protect_title", comment: ""))
            \(NSLocalizedString("privacy_protect_description", comment: ""))
            
            \(NSLocalizedString("what_we_collect", comment: ""))
            \(NSLocalizedString("on_device_only", comment: ""))
            \(NSLocalizedString("privacy_collect_1", comment: ""))
            \(NSLocalizedString("privacy_collect_2", comment: ""))
            \(NSLocalizedString("privacy_collect_3", comment: ""))
            \(NSLocalizedString("privacy_collect_4", comment: ""))
            
            \(NSLocalizedString("anonymous_usage_data", comment: ""))
            \(NSLocalizedString("privacy_anonymous_1", comment: ""))
            \(NSLocalizedString("privacy_anonymous_2", comment: ""))
            \(NSLocalizedString("privacy_anonymous_3", comment: ""))
            
            \(NSLocalizedString("where_data_lives", comment: ""))
            \(NSLocalizedString("privacy_data_1", comment: ""))
            \(NSLocalizedString("privacy_data_2", comment: ""))
            \(NSLocalizedString("privacy_data_3", comment: ""))
            \(NSLocalizedString("privacy_data_4", comment: ""))
            
            \(NSLocalizedString("camera_access", comment: ""))
            \(NSLocalizedString("privacy_camera_1", comment: ""))
            \(NSLocalizedString("privacy_camera_2", comment: ""))
            \(NSLocalizedString("privacy_camera_3", comment: ""))
            \(NSLocalizedString("privacy_camera_4", comment: ""))
            
            \(NSLocalizedString("what_we_dont_do", comment: ""))
            \(NSLocalizedString("privacy_dont_1", comment: ""))
            \(NSLocalizedString("privacy_dont_2", comment: ""))
            \(NSLocalizedString("privacy_dont_3", comment: ""))
            \(NSLocalizedString("privacy_dont_4", comment: ""))
            
            \(NSLocalizedString("kids_section", comment: ""))
            \(NSLocalizedString("privacy_kids", comment: ""))
            
            \(NSLocalizedString("your_rights", comment: ""))
            \(NSLocalizedString("privacy_rights_1", comment: ""))
            \(NSLocalizedString("privacy_rights_2", comment: ""))
            \(NSLocalizedString("privacy_rights_3", comment: ""))
            \(NSLocalizedString("privacy_rights_4", comment: ""))
            
            \(NSLocalizedString("privacy_questions", comment: ""))
            \(NSLocalizedString("privacy_contact", comment: ""))
            
            \(NSLocalizedString("privacy_trust", comment: ""))
            """

        case .about:
            return """
            \(NSLocalizedString("about_title", comment: ""))
            
            \(NSLocalizedString("version_label", comment: "")) \(getAppVersion()) • \(NSLocalizedString("version_made_with", comment: ""))
            
            \(NSLocalizedString("our_mission", comment: ""))
            \(NSLocalizedString("mission_description", comment: ""))
            
            \(NSLocalizedString("what_makes_special", comment: ""))
            
            \(NSLocalizedString("privacy_first", comment: ""))
            \(NSLocalizedString("about_privacy_1", comment: ""))
            \(NSLocalizedString("about_privacy_2", comment: ""))
            \(NSLocalizedString("about_privacy_3", comment: ""))
            
            \(NSLocalizedString("lightning_fast", comment: ""))
            \(NSLocalizedString("about_fast_1", comment: ""))
            \(NSLocalizedString("about_fast_2", comment: ""))
            \(NSLocalizedString("about_fast_3", comment: ""))
            \(NSLocalizedString("about_fast_4", comment: ""))
            
            \(NSLocalizedString("smart_simple", comment: ""))
            \(NSLocalizedString("about_smart_1", comment: ""))
            \(NSLocalizedString("about_smart_2", comment: ""))
            \(NSLocalizedString("about_smart_3", comment: ""))
            \(NSLocalizedString("about_smart_4", comment: ""))
            
            \(NSLocalizedString("built_with", comment: ""))
            \(NSLocalizedString("about_built_1", comment: ""))
            \(NSLocalizedString("about_built_2", comment: ""))
            \(NSLocalizedString("about_built_3", comment: ""))
            \(NSLocalizedString("about_built_4", comment: ""))
            
            \(NSLocalizedString("for_everyone", comment: ""))
            \(NSLocalizedString("about_everyone_1", comment: ""))
            \(NSLocalizedString("about_everyone_2", comment: ""))
            \(NSLocalizedString("about_everyone_3", comment: ""))
            \(NSLocalizedString("about_everyone_4", comment: ""))
            
            \(NSLocalizedString("coming_soon", comment: ""))
            \(NSLocalizedString("about_coming_1", comment: ""))
            \(NSLocalizedString("about_coming_2", comment: ""))
            \(NSLocalizedString("about_coming_3", comment: ""))
            \(NSLocalizedString("about_coming_4", comment: ""))
            \(NSLocalizedString("about_coming_5", comment: ""))
            
            \(NSLocalizedString("get_in_touch", comment: ""))
            
            \(NSLocalizedString("get_in_touch_description", comment: ""))
            \(NSLocalizedString("about_contact", comment: ""))
            
            \(NSLocalizedString("thank_you_title", comment: ""))
            \(NSLocalizedString("thank_you_message", comment: ""))
            
            \(NSLocalizedString("requirements_title", comment: ""))
            
            \(NSLocalizedString("about_requirements_1", comment: ""))
            \(NSLocalizedString("about_requirements_2", comment: ""))
            \(NSLocalizedString("about_requirements_3", comment: ""))
            \(NSLocalizedString("about_requirements_4", comment: ""))
            
            © \(getCurrentYear()) \(NSLocalizedString("copyright_text", comment: ""))
            \(NSLocalizedString("made_in_uk", comment: ""))
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
