import SwiftUI
import PhotosUI

class PhotosPickerViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var selectedPhotos: [PhotosPickerItem] = []

    @MainActor
    func convertDataToImage() {
        image = .none

        if let firstPhoto = selectedPhotos.first {
            Task {
                if let imageData = try? await firstPhoto.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: imageData) {
                        image = uiImage
                    }
                }
            }
        }
        
        selectedPhotos.removeAll()
    }
}

struct PhotosPickerView: View {
    @StateObject var vm = PhotosPickerViewModel()
    let onDisappear: (UIImage?) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Show selected image if available
            if let image = vm.image {
                ScrollView {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
            } else {
                // Placeholder when no image is selected
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No image selected")
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            // Photo picker button
            PhotosPicker(
                selection: $vm.selectedPhotos,
                maxSelectionCount: 1,
                selectionBehavior: .ordered,
                matching: .images
            ) {
                Label("Select a photo", systemImage: "photo")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            // Done button (optional)
            if vm.image != .none {
                Button("Done") {
                    onDisappear(vm.image)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Select Photo")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.selectedPhotos) { _, _ in
            vm.convertDataToImage()
        }
        .onDisappear {
            onDisappear(vm.image)
        }
    }
}
