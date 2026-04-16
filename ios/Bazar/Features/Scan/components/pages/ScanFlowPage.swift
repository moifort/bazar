import PhotosUI
import SwiftUI

struct ScanFlowPage: View {
    let step: ScanStep
    let errorMessage: String?
    @Binding var selectedPhoto: PhotosPickerItem?

    let onCapture: (Data) -> Void
    let onScanAnother: () -> Void
    let onConfirm: ([ItemPreview], String?) async -> Void
    let onDismiss: () -> Void
    let onErrorDismiss: () -> Void

    @State private var shouldCapture = false

    var body: some View {
        Group {
            switch step {
            case .camera:
                cameraStep

            case .scanning:
                AnalyzingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .preview(let previews, _):
                NavigationStack {
                    ScanConfirmationView(
                        previews: previews,
                        onScanAnother: onScanAnother,
                        onConfirm: { editedPreviews, storageId in
                            await onConfirm(editedPreviews, storageId)
                        }
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
        .alert("Erreur", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { onErrorDismiss() } }
        )) {
            Button("OK") { onErrorDismiss() }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var cameraStep: some View {
        ZStack {
            CameraView(
                onCapture: { data in onCapture(data) },
                shouldCapture: $shouldCapture
            )
            .ignoresSafeArea()

            ViewfinderOverlay()

            VStack {
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.glass)
                    .clipShape(.circle)
                    .accessibilityIdentifier("scan-close-button")
                    Spacer()
                }
                .padding()
                Spacer()
            }

            VStack {
                Spacer()
                bottomControls
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
    }

    @ViewBuilder
    private var bottomControls: some View {
        GlassEffectContainer(spacing: 24) {
            HStack {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: "photo")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.glass)
                .clipShape(.circle)
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
        }
    }
}

private struct AnalyzingView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ProgressView()
                .scaleEffect(2)

            VStack(spacing: 12) {
                Text("Analyse en cours")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Identification des objets…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview("Scanning") {
    AnalyzingView()
}
