import Foundation
import UIKit

struct OCRService {
    @concurrent
    func analyze(image: sending UIImage) async throws -> OCRResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OCRError.invalidImage
        }

        guard let url = URL(string: "\(await backendURL)/ocr") else {
            throw OCRError.invalidURL
        }
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeMultipartBody(imageData: imageData, boundary: boundary)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw OCRError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let detail = (try? JSONDecoder().decode([String: String].self, from: data))?["detail"] ?? "Unknown error"
            throw OCRError.serverError(detail)
        }

        guard let result = try? JSONDecoder().decode(OCRResult.self, from: data) else {
            throw OCRError.decodingError
        }

        return result
    }

    private func makeMultipartBody(imageData: Data, boundary: String) -> Data {
        var body = Data()
        let crlf = "\r\n"
        body.append("--\(boundary)\(crlf)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\(crlf)".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\(crlf)\(crlf)".data(using: .utf8)!)
        body.append(imageData)
        body.append("\(crlf)--\(boundary)--\(crlf)".data(using: .utf8)!)
        return body
    }
}
