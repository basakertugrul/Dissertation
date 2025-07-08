import SwiftUI

var appIconImage: Image {
    // Asset Catalog kontrolü
    if let assetCatalogPath = Bundle.main.path(forResource: "Assets", ofType: "car") {
        print("✅ Assets.car bulundu: \(assetCatalogPath)")
    } else {
        print("❌ Assets.car bulunamadı")
    }

    // Bundle identifier kontrolü
    print("📱 Bundle identifier: \(Bundle.main.bundleIdentifier ?? "nil")")

    // Tüm bundle resource'ları
    print("📁 Bundle resource keys: \(Bundle.main.infoDictionary?.keys.sorted() ?? [])")

    // Asset catalog'u kontrol et
    print("📱 Ana bundle path: \(Bundle.main.bundlePath)")
    return Image("elephantIcon")
        .resizable()
        .renderingMode(.template)
}
