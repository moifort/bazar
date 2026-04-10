import Foundation

enum ScanStep: Equatable {
    case camera
    case scanning
    case preview([ItemPreview], imageBase64: String)

    static func == (lhs: ScanStep, rhs: ScanStep) -> Bool {
        switch (lhs, rhs) {
        case (.camera, .camera), (.scanning, .scanning), (.preview, .preview):
            return true
        default:
            return false
        }
    }
}

@MainActor @Observable
final class ScanViewModel {
    var step: ScanStep = .camera
    var error: String?

    func capturePhoto(_ imageData: Data) {
        step = .scanning
        error = nil

        Task {
            do {
                let base64 = imageData.base64EncodedString()
                let previews = try await GraphQLScanAPI.analyze(imageBase64: base64)
                self.step = .preview(previews, imageBase64: base64)
            } catch {
                self.error = reportError(error)
                self.step = .camera
            }
        }
    }

    func confirmItems(_ previews: [ItemPreview], storageId: String?) async -> Bool {
        do {
            let inputs = previews.map { preview in
                ConfirmItemInput(
                    name: preview.name,
                    category: preview.category?.rawValue ?? ItemCategory.other.rawValue,
                    description: preview.description,
                    quantity: preview.quantity,
                    storageId: storageId,
                    previewImageBase64: nil
                )
            }
            try await GraphQLScanAPI.confirmItems(inputs)
            return true
        } catch {
            self.error = reportError(error)
            return false
        }
    }

    func reset() {
        step = .camera
        error = nil
    }
}
