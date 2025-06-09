import SwiftUI

/// Photo Thumbnail
struct PhotoThumbnail: View {
    @Binding var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 3)
                    .transition(.scale.combined(with: .opacity))
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            }
        }
    }
}
