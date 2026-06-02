import Foundation
import Testing
@testable import ArabicOCR

struct OCRErrorTests {
    @Test(arguments: [
        (OCRError.invalidImage, "Could not process the selected image."),
        (OCRError.serverError("503"), "Server error: 503"),
        (OCRError.decodingError, "Could not read the server response."),
    ])
    func describesError(error: OCRError, expected: String) {
        #expect(error.errorDescription == expected)
    }
}
