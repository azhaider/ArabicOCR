import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Label("Choose from Library", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .onChange(of: pickerItem) { _, newItem in
            loadTask?.cancel()
            loadTask = Task {
                do {
                    guard let newItem,
                          let data = try await newItem.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    try Task.checkCancellation()
                    selectedImage = image
                } catch is CancellationError {
                    // Superseded by a newer selection — ignore.
                } catch {
                    showErrorAlert = true
                    pickerItem = nil
                    errorMessage = "Sorry, error occurred. \(error.localizedDescription)"
                }
            }
        }
        .alert("Loading Failed", isPresented: $showErrorAlert) { } message: {
            Text(errorMessage)
        }
    }
}
