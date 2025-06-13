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
