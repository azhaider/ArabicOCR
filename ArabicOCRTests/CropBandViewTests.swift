import Foundation
import Testing
@testable import ArabicOCR
internal import CoreGraphics

@MainActor
struct CropBandViewTests {
    /// A device's logical screen size in points (portrait).
    nonisolated struct Device: CustomTestStringConvertible {
        let name: String
        let size: CGSize
        var testDescription: String { name }
    }

    @Test(arguments: [
        Device(name: "iPhone SE (3rd gen)", size: CGSize(width: 375, height: 667)),
        Device(name: "iPhone 17 Pro", size: CGSize(width: 402, height: 874)),
    ])
    func bandRectScalesAndStaysCentered(device: Device) {
        let view = CropBandView(frame: CGRect(origin: .zero, size: device.size))
        let band = view.bandRect

        // The band keeps its configured proportions on every screen size.
        #expect(band.width == device.size.width * 0.88)
        #expect(band.height == device.size.height * 0.18)

        // ...and stays centered regardless of device.
        #expect(band.midX == device.size.width / 2)
        #expect(band.midY == device.size.height / 2)
    }
}
