import SwiftUI

/// Read-only row of search keywords, wrapped over as many lines as it takes.
/// Renders nothing when there is no keyword — an empty chip row reads as broken.
struct TagChips: View {
    let tags: [String]
    var font: Font = .subheadline

    var body: some View {
        if !tags.isEmpty {
            FlowLayout(spacing: 6, lineSpacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(font)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.fill.tertiary, in: .capsule)
                }
            }
            // A row narrower than its container would otherwise centre itself.
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Mots-clés : \(tags.joined(separator: ", "))")
        }
    }
}

#Preview("Plein") {
    TagChips(tags: ["cumin", "paprika", "curry", "épice", "condiment", "cuisine"])
        .padding()
}

#Preview("Vide") {
    TagChips(tags: [])
        .padding()
}
