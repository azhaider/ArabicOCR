import Foundation
import Testing
@testable import ArabicOCR

struct OCRResultTests {
    @Test func decodesSnakeCaseKeys() throws {
        let json = Data("""
        {
            "arabic_text": "مرحبا",
            "english_translation": "Hello",
            "source": "Greeting"
        }
        """.utf8)

        let result = try JSONDecoder().decode(OCRResult.self, from: json)

        #expect(result.arabicText == "مرحبا")
        #expect(result.englishTranslation == "Hello")
        #expect(result.source == "Greeting")
    }
}
