import Foundation

enum ScanStep: Equatable {
    case camera
    case scanning
    case preview([ItemPreview])

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
                self.step = .preview(previews)
            } catch {
                self.error = reportError(error)
                self.step = .camera
            }
        }
    }

    func confirmItems(_ previews: [ItemPreview], location: LocationSelection) async -> Bool {
        do {
            let inputs = previews.map { preview in
                ConfirmItemInput(
                    name: preview.name,
                    category: preview.category?.rawValue ?? ItemCategory.other.rawValue,
                    description: preview.description,
                    quantity: preview.quantity,
                    storageId: location.storageId,
                    zoneId: location.zoneId,
                    personalNotes: preview.personalNotes,
                    purchaseDate: preview.purchaseDate,
                    purchaseLocation: preview.purchaseLocation,
                    purchaseCondition: preview.purchaseCondition
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
