import AVFoundation
import UIKit

final class CameraViewController: UIViewController {
    private enum CaptureMode {
        case fullPage, lines
    }

    var onCapture: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    private let cameraSession = CameraSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isSessionConfigured = false
    private let cropBand = CropBandView()
    private var captureMode: CaptureMode = .fullPage

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPreviewLayer()
        setupCancelButton()
        Task { await setUpCameraIfAuthorized() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard isSessionConfigured else { return }
        cameraSession.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraSession.stop()
    }
}

// MARK: - Session

private extension CameraViewController {
    func setUpCameraIfAuthorized() async {
        guard await CameraPermission.requestAccess() else { return showPermissionDenied() }
        let configured = await cameraSession.configureAndStart()
        if configured {
            isSessionConfigured = true
            setupCaptureUI()
        }
    }

    func setupPreviewLayer() {
        let layer = cameraSession.makePreviewLayer()
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
        previewLayer = layer
    }
}

// MARK: - UI

private extension CameraViewController {
    func setupCancelButton() {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tintColor = .white
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        ])
    }

    /// Adds the band overlay, mode toggle, and shutter — only once the session is
    /// configured (i.e. camera access is granted).
    func setupCaptureUI() {
        cropBand.frame = view.bounds
        cropBand.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cropBand.isHidden = captureMode == .fullPage
        view.addSubview(cropBand)

        let modeControl = UISegmentedControl(items: ["Full Page", "Lines"])
        modeControl.selectedSegmentIndex = 0
        modeControl.selectedSegmentTintColor = .white
        modeControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        modeControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        modeControl.translatesAutoresizingMaskIntoConstraints = false
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        view.addSubview(modeControl)

        let captureButton = UIButton(type: .system)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.accessibilityLabel = "Capture photo"
        captureButton.accessibilityIdentifier = "capture.button"
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            modeControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
        ])
    }

    func showPermissionDenied() {
        let label = UILabel()
        label.text = "Camera access is off. Enable it in Settings to scan documents."
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center

        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Open Settings", for: .normal)
        settingsButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        settingsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, settingsButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])
    }
}

// MARK: - Actions

private extension CameraViewController {
    @objc func modeChanged(_ sender: UISegmentedControl) {
        captureMode = sender.selectedSegmentIndex == 1 ? .lines : .fullPage
        cropBand.isHidden = captureMode == .fullPage
    }

    @objc func capturePhoto() {
        cameraSession.capturePhoto(delegate: self)
    }

    @objc func cancel() {
        onCancel?()
    }

    @objc func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Photo capture

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        if let error {
            Task { @MainActor [weak self] in
                guard let self else { return }
                let alert = UIAlertController(
                    title: "Capture Failed",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
            return
        }
        guard let data = photo.fileDataRepresentation() else { return }
        Task { @MainActor in
            guard let image = UIImage(data: data) else { return }
            onCapture?(processedImage(image))
        }
    }

    /// In Lines mode, crops the captured photo to the on-screen band; otherwise returns it unchanged.
    @MainActor
    private func processedImage(_ image: UIImage) -> UIImage {
        guard captureMode == .lines, let previewLayer else { return image }
        return BandCropper.crop(image, to: cropBand.bandRect, using: previewLayer)
    }
}
