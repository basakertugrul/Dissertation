import UIKit

// MARK: - Haptic Feedback Types
enum HapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
    case buttonTap
    case navigation
    case notification
    case longPress
    case swipe
    case delete
    case add
    case edit
    case login
    case logout
    case purchase
    case cancel
}

// MARK: - Haptic Manager
final class HapticManager {
    static let shared = HapticManager()
    
    private init() {
        prepareHaptics()
    }
    
    // MARK: - Haptic Generators
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    // MARK: - Settings
    private var isHapticEnabled: Bool {
        return UserDefaults.standard.object(forKey: "haptic_enabled") as? Bool ?? true
    }
    
    // MARK: - Main Trigger Method
    
    /// Trigger haptic feedback for specific type
    func trigger(_ type: HapticType) {
        guard isHapticEnabled else { return }
        
        switch type {
        case .light:
            lightImpact.impactOccurred()
            
        case .medium:
            mediumImpact.impactOccurred()
            
        case .heavy:
            heavyImpact.impactOccurred()
            
        case .success:
            notificationFeedback.notificationOccurred(.success)
            
        case .warning:
            notificationFeedback.notificationOccurred(.warning)
            
        case .error:
            notificationFeedback.notificationOccurred(.error)
            
        case .selection:
            selectionFeedback.selectionChanged()
            
        case .buttonTap:
            mediumImpact.impactOccurred()
            
        case .navigation:
            lightImpact.impactOccurred()
            
        case .notification:
            heavyImpact.impactOccurred()
            
        case .longPress:
            heavyImpact.impactOccurred()
            
        case .swipe:
            lightImpact.impactOccurred()
            
        case .delete:
            notificationFeedback.notificationOccurred(.warning)
            
        case .add:
            notificationFeedback.notificationOccurred(.success)
            
        case .edit:
            selectionFeedback.selectionChanged()
            
        case .login:
            notificationFeedback.notificationOccurred(.success)
            
        case .logout:
            mediumImpact.impactOccurred()
            
        case .purchase:
            notificationFeedback.notificationOccurred(.success)
            
        case .cancel:
            lightImpact.impactOccurred()
        }
    }
    
    // MARK: - Setup Methods
    
    /// Prepare haptics for better performance
    private func prepareHaptics() {
        guard isHapticEnabled else { return }
        
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    /// Enable or disable haptic feedback
    func setHapticEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "haptic_enabled")
        
        if enabled {
            prepareHaptics()
        }
    }
    
    /// Check if device supports haptics
    var isHapticSupported: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}
