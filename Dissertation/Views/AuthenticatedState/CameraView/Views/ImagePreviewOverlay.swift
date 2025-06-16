import SwiftUI

/// Image Preview Overlay
struct ImagePreviewOverlay: View {
    let image: UIImage
    @Binding var isVisible: Bool
    var viewModel: CameraViewModel
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.smooth()) {
                        isVisible = false
                    }
                }

            VStack {

                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

            Spacer()
            HStack(spacing: Constraint.largePadding) {
                Button(action: {
                    /// Option to retake photo
                    withAnimation(.smooth()) {
                        isVisible = false
                        viewModel.capturedImage = nil
                    }
                }) {
                    VStack {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .font(.system(size: Constraint.extremeIconSize))
                        CustomTextView(
                            "Retake",
                            font: .labelLargeBold
                        )
                    }
                    .foregroundColor(.customBurgundy)
                }
                Button(action: {
                    /// Option to use image (save or select for expense)
                    withAnimation(.smooth()) {
                        viewModel.saveImageToGallery(image: image) // ww: 1
                    }
                }) {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: Constraint.extremeIconSize))
                        CustomTextView(
                            "Use",
                            font: .labelLargeBold
                        )
                    }
                    .foregroundColor(.customOliveGreen)
                }
            }
            .padding(.bottom, Constraint.largePadding)
            }
        }
    }
}
