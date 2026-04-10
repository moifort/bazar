import SwiftUI

struct LocationRow: View {
    let name: String
    let icon: String
    let depth: Int

    var body: some View {
        Label {
            Text(name)
                .font(depth == 0 ? .headline : .body)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(colorForDepth)
        }
    }

    private var colorForDepth: Color {
        switch depth {
        case 0: .blue
        case 1: .green
        case 2: .orange
        default: .purple
        }
    }
}

#Preview {
    List {
        LocationRow(name: "Maison", icon: "house", depth: 0)
        LocationRow(name: "Salon", icon: "sofa", depth: 1)
        LocationRow(name: "Meuble TV", icon: "rectangle.split.3x1", depth: 2)
        LocationRow(name: "Tiroir gauche", icon: "archivebox", depth: 3)
    }
}
