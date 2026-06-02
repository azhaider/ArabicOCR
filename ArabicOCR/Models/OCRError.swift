import Foundation

nonisolated enum OCRError: LocalizedError {
    case invalidImage
    case invalidURL
    case networkError(Error)
    case serverError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the selected image."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let detail):
            return "Server error: \(detail)"
        case .decodingError:
            return "Could not read the server response."
        case .invalidURL:
            return "Invalid backend URL"
        }
    }
}
