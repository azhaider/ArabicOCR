import AVFoundation

/// Camera authorization helper.
enum CameraPermission {
    /// Returns whether camera access is granted, prompting the user the first time
    /// if they haven't been asked yet.
    static func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}
