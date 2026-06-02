import SwiftUI

struct ResultsView: View {
    let result: OCRResult
    let onScanAnother: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ResultSection(title: "Arabic Text") {
                    Text(result.arabicText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                        .environment(\.layoutDirection, .rightToLeft)
                }

                ResultSection(title: "English Translation") {
                    Text(result.englishTranslation)
                        .textSelection(.enabled)
                }

                ResultSection(title: "Source") {
                    Text(result.source)
                        .italic()
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Button(action: onScanAnother) {
                    Text("Scan Another")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ResultSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

