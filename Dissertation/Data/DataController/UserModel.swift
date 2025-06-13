import Foundation

struct User: Codable {
    let fullName: String
    let email: String
    let authState: String
    var hasFaceIDEnabled: Bool
}
