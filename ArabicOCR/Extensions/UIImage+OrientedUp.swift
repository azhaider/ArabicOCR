import UIKit

extension UIImage {
    /// Returns a copy with the orientation baked into the pixel data (`.up`), so the
    /// underlying `CGImage` is laid out the same way it appears on screen. This lets a
    /// normalized crop rect (from `AVCaptureVideoPreviewLayer.metadataOutputRectConverted`)
    /// map directly onto `CGImage` pixels.
    func orientedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
