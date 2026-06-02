import AVFoundation

final class CameraSession: @unchecked Sendable {
    /// nonisolated(unsafe) because AVCaptureSession must be accessed on the dedicated
    /// serial queue; Swift actors use the cooperative pool, which AVFoundation does not support.
    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private let output = AVCapturePhotoOutput()

    private let queue = DispatchQueue(label: "com.aizaz.ocr.cam")

    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }

    /// Configures the capture session on the dedicated queue and starts it.
    /// Returns whether configuration succeeded. Safe to call from any actor.
    func configureAndStart() async -> Bool {
        await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self else { continuation.resume(returning: false); return }
                let success = runConfiguration()
                if success { session.startRunning() }
                continuation.resume(returning: success)
            }
        }
    }

    func start() {
        queue.async { [session] in session.startRunning() }
    }

    func stop() {
        queue.async { [session] in session.stopRunning() }
    }

    func capturePhoto(delegate: AVCapturePhotoCaptureDelegate) {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: delegate)
    }

    private func runConfiguration() -> Bool {
        session.sessionPreset = .photo
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(output)
        else { return false }

        session.beginConfiguration()
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
        return true
    }
}
