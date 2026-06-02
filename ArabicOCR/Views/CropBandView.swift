import UIKit

/// A fixed, horizontally-centered capture band drawn over the camera preview.
///
/// Purely visual — it never intercepts touches (`isUserInteractionEnabled = false`),
/// so the camera controls underneath stay tappable. Shown only in "Lines" mode.
final class CropBandView: UIView {
    /// Band width as a fraction of the view's width.
    var widthRatio: CGFloat = 0.88 { didSet { setNeedsDisplay() } }
    /// Band height as a fraction of the view's height.
    var heightRatio: CGFloat = 0.18 { didSet { setNeedsDisplay() } }

    /// The band rectangle, in this view's coordinate space.
    var bandRect: CGRect {
        let w = bounds.width * widthRatio
        let h = bounds.height * heightRatio
        return CGRect(x: (bounds.width - w) / 2,
                      y: (bounds.height - h) / 2,
                      width: w, height: h)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        contentMode = .redraw

        isAccessibilityElement = true
        accessibilityLabel = "Capture band"
        accessibilityHint = "Only text inside this band will be scanned."
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), bounds.width > 0 else { return }
        let band = bandRect

        // Dim everything outside the band.
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        ctx.fill(bounds)
        ctx.clear(band)

        // Band border.
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineWidth(2)
        ctx.stroke(band)
    }
}
