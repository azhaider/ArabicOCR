import Foundation

nonisolated struct OCRResult: Codable, Identifiable, Hashable {
    let id = UUID()
    let arabicText: String
    let englishTranslation: String
    let source: String

    enum CodingKeys: String, CodingKey {
        case arabicText = "arabic_text"
        case englishTranslation = "english_translation"
        case source
    }
}

