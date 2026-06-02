import AVFoundation
import UIKit

/// Crops a captured photo to a rectangle expressed in preview-layer coordinates.
enum BandCropper {
    /// Crops `image` to `rect` (in `previewLayer`'s coordinate space), accounting for the
    /// preview's aspect-fill gravity and the image's orientation. Returns the original image
    /// unchanged if the crop can't be computed.
    @MainActor
    static func crop(_ image: UIImage,
                     to rect: CGRect,
                     using previewLayer: AVCaptureVideoPreviewLayer) -> UIImage {
        // Normalized rect (0...1, top-left origin) in the captured image.
        let meta = previewLayer
            .metadataOutputRectConverted(fromLayerRect: rect)
            .intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
        guard !meta.isNull, meta.width > 0, meta.height > 0 else { return image }

        // Bake orientation so CGImage pixels match the displayed orientation.
        let oriented = image.orientedUp()
        guard let cg = oriented.cgImage else { return image }
        let width = CGFloat(cg.width), height = CGFloat(cg.height)
        let cropPixels = CGRect(x: meta.minX * width, y: meta.minY * height,
                                width: meta.width * width, height: meta.height * height).integral
        guard let cropped = cg.cropping(to: cropPixels) else { return image }
        return UIImage(cgImage: cropped, scale: oriented.scale, orientation: .up)
    }
}
