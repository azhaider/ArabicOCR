import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var selectedImage: UIImage?
    @State private var showCamera = false

    @ScaledMetric(relativeTo: .title) var iconSize: CGFloat = 72

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: iconSize))
                    .foregroundStyle(.foreground)
                    .accessibilityHidden(true)

                Text("Arabic OCR")
                    .font(.largeTitle)
                    .bold()

                Text("Scan or select an Arabic document to extract, translate, and identify the text.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer()

                if viewModel.isLoading {
                    LoadingView()
                } else {
                    VStack(spacing: 12) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Scan Document", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        PhotoPickerView(selectedImage: $selectedImage)
                    }
                    .padding(.horizontal)
                }

                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationDestination(item: $vm.result) { result in
                ResultsView(result: result) {
                    viewModel.result = nil
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { image in
                    selectedImage = image
                }
            }
            .onChange(of: selectedImage) { _, image in
                guard let image else { return }
                selectedImage = nil
                viewModel.analyze(image: image)
            }
            .onDisappear {
                viewModel.cancelAnalysis()
            }
        }
    }
}
