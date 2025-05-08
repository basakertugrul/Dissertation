import Foundation

enum SplineURL {
    case bunny
    case bunnyParty

    func get() -> URL? {
        switch self {
        case .bunny:
            return URL(string: "https://build.spline.design/ievQcbiTtvr8RKkllXpD/scene.splineswift")
        case .bunnyParty:
            return URL(string: "https://build.spline.design/CzB1EyfMExsHzLvEvRsJ/scene.splineswift")
        }
    }
}
