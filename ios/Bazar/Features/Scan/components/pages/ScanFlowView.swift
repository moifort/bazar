import PhotosUI
import SwiftUI

struct ScanFlowView: View {
    var onFlowCompleted: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ScanViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var shouldCapture = false

    var body: some View {
        Group {
            switch viewModel.step {
            case .camera:
                cameraStep

            case .scanning:
                AnalyzingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .preview(let previews, let imageBase64):
                NavigationStack {
                    ScanConfirmationView(
                        previews: previews,
                        onScanAnother: { viewModel.reset() },
                        onConfirm: { editedPreviews, storageId in
                            guard let _ = await viewModel.confirmItems(editedPreviews, storageId: storageId) else {
                                return
                            }
                            viewModel.reset()
                            onFlowCompleted()
                        }
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
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
        .alert("Erreur", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    // MARK: - Camera Step

    @ViewBuilder
    private var cameraStep: some View {
        ZStack {
            CameraView(onCapture: { data in
                viewModel.capturePhoto(data)
            }, shouldCapture: $shouldCapture)
                .ignoresSafeArea()

            ViewfinderOverlay()

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: .circle)
                    }
                    .accessibilityIdentifier("scan-close-button")
                    Spacer()
                }
                .padding()
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(.ultraThinMaterial, in: .circle)
                    }
                    .accessibilityIdentifier("scan-photo-picker")
                    Spacer()
                    Button {
                        shouldCapture = true
                    } label: {
                        Circle()
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .accessibilityIdentifier("scan-capture-button")
                    Spacer()
                    Color.clear.frame(width: 56, height: 56)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Analyzing View

private struct AnalyzingView: View {
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                ProgressView()
                    .scaleEffect(2)
            }

            VStack(spacing: 12) {
                Text("Analyse en cours")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Identification des objets...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}

#Preview("Analyzing") {
    AnalyzingView()
}
