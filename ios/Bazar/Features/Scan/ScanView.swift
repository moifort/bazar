import PhotosUI
import SwiftUI

struct ScanView: View {
    var onFlowCompleted: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ScanViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        ScanFlowPage(
            step: viewModel.step,
            errorMessage: viewModel.error,
            selectedPhoto: $selectedPhoto,
            onCapture: { viewModel.capturePhoto($0) },
            onScanAnother: { viewModel.reset() },
            onConfirm: { previews, storageId in
                guard await viewModel.confirmItems(previews, storageId: storageId) else { return }
                viewModel.reset()
                onFlowCompleted()
            },
            onDismiss: { dismiss() },
            onErrorDismiss: { viewModel.error = nil }
        )
        .onChange(of: selectedPhoto) {
            guard let item = selectedPhoto else { return }
            selectedPhoto = nil
            viewModel.step = .scanning
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let jpeg = image.resized(maxDimension: 800).jpegData(compressionQuality: 0.6) {
                    viewModel.capturePhoto(jpeg)
                } else {
                    viewModel.step = .camera
                }
            }
        }
    }
}
