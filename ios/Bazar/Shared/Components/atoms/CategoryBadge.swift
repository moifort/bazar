import SwiftUI

struct CategoryBadge: View {
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.15), in: .capsule)
    }
}

#Preview {
    HStack(spacing: 8) {
        CategoryBadge(label: "Outils", icon: "wrench.and.screwdriver", color: .orange)
        CategoryBadge(label: "Électronique", icon: "desktopcomputer", color: .cyan)
        CategoryBadge(label: "Livres", icon: "book", color: .teal)
        CategoryBadge(label: "Autre", icon: "questionmark.folder", color: .secondary)
    }
    .padding()
}
