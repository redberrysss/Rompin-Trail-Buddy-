import SwiftUI
import UIKit
import AVFoundation

struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    var sourceType: UIImagePickerController.SourceType = .camera

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let captured = info[.originalImage] as? UIImage {
                parent.image = captured
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct CameraPermissionView: View {
    @Binding var isPresented: Bool
    @State private var permissionStatus: AVAuthorizationStatus = .notDetermined
    @State private var showDeniedAlert = false

    var body: some View {
        Group {
            switch permissionStatus {
            case .authorized:
                CameraCaptureView(image: .constant(nil))
                    .ignoresSafeArea()

            case .notDetermined, .restricted:
                requestingView

            case .denied:
                deniedView

            @unknown default:
                deniedView
            }
        }
        .task {
            await checkPermission()
        }
        .alert("Akses Kamera Diperlukan", isPresented: $showDeniedAlert) {
            Button("Buka Tetapan") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Batal", role: .cancel) {
                isPresented = false
            }
        } message: {
            Text("Sila benarkan akses kamera dalam tetapan untuk mengambil gambar.")
        }
    }

    private var requestingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.forestGreen)

            Text("Memohon akses kamera...")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            ProgressView()
                .tint(AppTheme.forestGreen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundGradient)
        .task {
            await requestCameraPermission()
        }
    }

    private var deniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.secondaryText)

            Text("Akses Kamera Ditolak")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Sila pergi ke Tetapan untuk membenarkan akses kamera.")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            LargeActionButton(
                title: "Buka Tetapan",
                icon: "gearshape.fill"
            ) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }

            LargeActionButton(
                title: "Batal",
                icon: "xmark",
                color: AppTheme.secondaryText
            ) {
                isPresented = false
            }
        }
        .padding(AppTheme.standardPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundGradient)
    }

    @MainActor
    private func checkPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    @MainActor
    private func requestCameraPermission() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        permissionStatus = granted ? .authorized : .denied
        if !granted {
            showDeniedAlert = true
        }
    }
}

#Preview {
    CameraPermissionView(isPresented: .constant(true))
}
