import Foundation

// MARK: - User Management
struct User {
    let id: UUID
    let email: String?
    let displayName: String?
    let createdAt: Date
    var hasFaceIDEnabled: Bool
    let authState: AuthState

    init(id: UUID = UUID(),
         email: String? = nil,
         displayName: String? = nil,
         createdAt: Date = Date(),
         hasFaceIDEnabled: Bool = false,
         authState: AuthState = .notFound) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.hasFaceIDEnabled = hasFaceIDEnabled
        self.authState = authState
    }
}

enum AuthState {
    case authorized
    case revoked
    case transferred
    case notFound
}
