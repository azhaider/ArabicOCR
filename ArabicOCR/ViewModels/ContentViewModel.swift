import SwiftUI

@MainActor
@Observable
final class ContentViewModel {
    var result: OCRResult?
    var error: OCRError?
    var isLoading = false

    private var analyzeTask: Task<Void, Never>?
    private let service = OCRService()

    func analyze(image: UIImage) {
        analyzeTask?.cancel()
        isLoading = true
        error = nil
        analyzeTask = Task {
            defer { isLoading = false }
            do {
                result = try await service.analyze(image: image)
            } catch is CancellationError {
                // View disappeared or a new image was selected.
            } catch let ocrError as OCRError {
                error = ocrError
            } catch {
                self.error = .networkError(error)
            }
        }
    }

    func cancelAnalysis() {
        analyzeTask?.cancel()
    }
}
