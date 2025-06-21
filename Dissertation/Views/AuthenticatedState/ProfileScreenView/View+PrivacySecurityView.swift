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
        case dataProtection = "Data Protection"
        case permissions = "App Permissions"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(Constraint.Opacity.medium).ignoresSafeArea()
            Rectangle()
                .fill(.ultraThinMaterial.opacity(Constraint.Opacity.medium))
                .ignoresSafeArea()
                .onTapGesture { isShowing = false }

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
                        getContentView(for: selectedSection)
                            .padding(Constraint.padding)
                    }
                    .background(Color.customWhiteSand)
                    
                } else {
                    // Main Header
                    HStack(alignment: .lastTextBaseline) {
                        CustomNavigationBarTitleView(title: createTitle("Privacy & Security"))
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
                        ForEach(PrivacySection.allCases, id: \.self) { section in
                            Button {
                                withAnimation {
                                    selectedSection = section
                                }
                            } label: {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        CustomTextView(
                                            section.rawValue,
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
                "Your Data is Safe",
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            CustomTextView(
                """
                • All expense data is stored locally on your device
                • No financial information is transmitted to external servers
                • Data is encrypted using industry-standard AES-256 encryption
                • We don't sell or share your personal information
                • No third-party tracking or analytics
                """,
                font: .labelLarge,
                color: .customRichBlack,
                alignment: .leading
            )
            
            CustomTextView(
                "Data Retention",
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            CustomTextView(
                "Your data remains on your device until you choose to delete the app. We don't automatically collect or backup your information.",
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
                    "Biometric Authentication",
                    font: .bodyLargeBold,
                    color: .customRichBlack
                )
                Spacer()
                CustomTextView(
                    "Enabled",
                    font: .labelMedium,
                    color: .customOliveGreen
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Constraint.regularCornerRadius)
            
            CustomTextView(
                "Security Features:",
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            CustomTextView(
                """
                • Face ID / Touch ID protection
                • App automatically locks when backgrounded
                • Secure data encryption
                • No cloud storage of sensitive data
                • Regular security updates
                """,
                font: .labelLarge,
                color: .customRichBlack,
                alignment: .leading
            )
        }
    }
    
    private var permissionsView: some View {
        VStack(alignment: .leading, spacing: Constraint.padding) {
            CustomTextView(
                "App Permissions",
                font: .bodyLargeBold,
                color: .customOliveGreen
            )
            
            VStack(spacing: Constraint.smallPadding) {
                permissionRow(
                    icon: "camera.fill",
                    title: "Camera Access",
                    description: "For receipt scanning and expense photos",
                    status: "Optional"
                )
                
                permissionRow(
                    icon: "photo.fill",
                    title: "Photo Library",
                    description: "To save and access receipt images",
                    status: "Optional"
                )
                
                permissionRow(
                    icon: "faceid",
                    title: "Biometric Data",
                    description: "For secure app authentication",
                    status: "Recommended"
                )
            }
            
            CustomTextView(
                "You can manage these permissions in your device Settings > FundBud",
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
                color: status == "Recommended" ? .customOliveGreen : .customRichBlack.opacity(Constraint.Opacity.medium)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Constraint.regularCornerRadius)
    }
    
    private func getSubtitle(for section: PrivacySection) -> String {
        switch section {
        case .dataProtection:
            return "How we protect your information"
        case .permissions:
            return "Control app access to device features"
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
