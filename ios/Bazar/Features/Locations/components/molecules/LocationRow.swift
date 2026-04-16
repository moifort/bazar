import SwiftUI

struct LocationRow: View {
    let name: String
    let icon: String

    var body: some View {
        Label(name, systemImage: icon)
    }
}

#Preview {
    List {
        LocationRow(name: "Maison", icon: "house")
        LocationRow(name: "Salon", icon: "sofa")
        LocationRow(name: "Meuble TV", icon: "rectangle.split.3x1")
        LocationRow(name: "Tiroir gauche", icon: "archivebox")
    }
}
