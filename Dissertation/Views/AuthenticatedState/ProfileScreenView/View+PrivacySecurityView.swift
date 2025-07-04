import SwiftUI

extension View {
    /// Show Privacy & Security Settings Alert
    func showPrivacySecurityAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                PrivacySecurityOverlay(isShowing: isPresented)
                    .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
}

struct PrivacySecurityOverlay: View {
    @Binding var isShowing: Bool
    @State private var selectedSection: PrivacySection? = nil
    
    enum PrivacySection: String, CaseIterable {
        case dataProtection = "dataProtection"
        case permissions = "permissions"
        
        var displayName: String {
            switch self {
            case .dataProtection: return NSLocalizedString("data_protection", comment: "")
            case .permissions: return NSLocalizedString("app_permissions", comment: "")
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
                        getContentView(for: selectedSection)
                            .padding(Constraint.padding)
                    }
                    .background(Color.customWhiteSand)
                    
                } else {
                    // Main Header
                    HStack(alignment: .lastTextBaseline) {
                        CustomNavigationBarTitleView(title: createTitle(NSLocalizedString("privacy_security_title", comment: "")))
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
                        ForEach(PrivacySection.allCases, id: \.self) { section in
                            Button {
                                HapticManager.shared.trigger(.navigation)
                                withAnimation {
                                    selectedSection = section
                                }
                            } label: {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        CustomTextView(
                                            section.displayName,
                                            font: .bodySmall,
                                            color: .customRichBlack
                                        )
                                        CustomTextView(
                                            getSubtitle(for: section),
                                            font: .labelMedium,
                                            color: .customRichBlack.opacity(Constraint.Opacity.medium)
                                        )
                                    }
                                    Spacer()
                                    Image(systemName: getIcon(for: section))
                                        .foregroundColor(.customRichBlack.opacity(0.4))
                                }
                                .padding()
                                .background(Color.white)
                            }
                            
                            if section != PrivacySection.allCases.last {
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
    
    private func getContentView(for section: PrivacySection) -> some View {
        VStack(alignment: .leading, spacing: Constraint.largePadding) {
            switch section {
            case .dataProtection:
                dataProtectionView
            case .permissions:
                permissionsView
            }
        }
    }
    
    private var dataProtectionView: some View {
        VStack(alignment: .leading, spacing: Constraint.padding) {
            CustomTextView(
                NSLocalizedString("your_data_safe", comment: ""),
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            CustomTextView(
                NSLocalizedString("data_protection_content", comment: ""),
                font: .labelLarge,
                color: .customRichBlack,
                alignment: .leading
            )
            
            CustomTextView(
                NSLocalizedString("data_retention_title", comment: ""),
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            CustomTextView(
                NSLocalizedString("data_retention_content", comment: ""),
                font: .labelLarge,
                color: .customRichBlack,
                alignment: .leading
            )
        }
    }
    
    private var securitySettingsView: some View {
        VStack(alignment: .leading, spacing: Constraint.padding) {
            HStack {
                Image(systemName: "faceid")
                    .foregroundColor(.customOliveGreen)
                CustomTextView(
                    NSLocalizedString("biometric_authentication", comment: ""),
                    font: .bodyLargeBold,
                    color: .customRichBlack
                )
                Spacer()
                CustomTextView(
                    NSLocalizedString("enabled", comment: ""),
                    font: .labelMedium,
                    color: .customOliveGreen
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Constraint.regularCornerRadius)
            
            CustomTextView(
                NSLocalizedString("security_features", comment: ""),
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            CustomTextView(
                NSLocalizedString("security_features_content", comment: ""),
                font: .labelLarge,
                color: .customRichBlack,
                alignment: .leading
            )
        }
    }
    
    private var permissionsView: some View {
        VStack(alignment: .leading, spacing: Constraint.padding) {
            CustomTextView(
                NSLocalizedString("app_permissions", comment: ""),
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            VStack(spacing: Constraint.smallPadding) {
                permissionRow(
                    icon: "camera.fill",
                    title: NSLocalizedString("camera_access", comment: ""),
                    description: NSLocalizedString("camera_description", comment: ""),
                    status: NSLocalizedString("optional", comment: "")
                )
                
                permissionRow(
                    icon: "photo.fill",
                    title: NSLocalizedString("photo_library", comment: ""),
                    description: NSLocalizedString("photo_library_description", comment: ""),
                    status: NSLocalizedString("optional", comment: "")
                )
                
                permissionRow(
                    icon: "faceid",
                    title: NSLocalizedString("biometric_data", comment: ""),
                    description: NSLocalizedString("biometric_description", comment: ""),
                    status: NSLocalizedString("recommended", comment: "")
                )
            }
            
            CustomTextView(
                NSLocalizedString("permissions_settings_note", comment: ""),
                font: .labelMedium,
                color: .customRichBlack.opacity(Constraint.Opacity.medium)
            )
        }
    }
    
    private func permissionRow(icon: String, title: String, description: String, status: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.customOliveGreen)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                CustomTextView(title, font: .labelLarge, color: .customRichBlack)
                CustomTextView(description, font: .labelMedium, color: .customRichBlack.opacity(Constraint.Opacity.medium))
            }
            
            Spacer()
            
            CustomTextView(
                status,
                font: .labelMedium,
                color: status == NSLocalizedString("recommended", comment: "") ? .customOliveGreen : .customRichBlack.opacity(Constraint.Opacity.medium)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Constraint.regularCornerRadius)
    }
    
    private func getSubtitle(for section: PrivacySection) -> String {
        switch section {
        case .dataProtection:
            return NSLocalizedString("data_protection_subtitle", comment: "")
        case .permissions:
            return NSLocalizedString("app_permissions_subtitle", comment: "")
        }
    }
    
    private func getIcon(for section: PrivacySection) -> String {
        switch section {
        case .dataProtection:
            return "shield.fill"
        case .permissions:
            return "checkmark.shield.fill"
        }
    }
    
    private func createTitle(_ text: String) -> AttributedString {
        var title = AttributedString(text)
        title.foregroundColor = .customRichBlack
        title.font = TextFonts.titleSmallBold.font
        return title
    }
}
