import SwiftUI

/// Photo Thumbnail
struct PhotoThumbnail: View {
    var body: some View {
        Circle()
            .foregroundColor(Color.gray.opacity(0.2))
            .frame(width: 45, height: 45)
            .overlay(
                Image(systemName: "photo.stack")
                    .foregroundColor(.white)
            )
    }
}
