import SwiftUI

struct LabeledInfoRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        Label {
            LabeledContent(title, value: value)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        LabeledInfoRow(title: "Catégorie", value: "Outils", icon: "tag")
        LabeledInfoRow(title: "Quantité", value: "3", icon: "number")
        LabeledInfoRow(title: "Lieu", value: "Maison > Garage", icon: "mappin")
    }
}
