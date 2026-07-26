import SwiftUI

/// Editable list of search keywords: a text field that turns what is typed into
/// a chip on submit, and chips that drop on tap.
struct TagField: View {
    @Binding var tags: [String]
    var placeholder: String = "Ajouter un mot-clé"

    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !tags.isEmpty {
                FlowLayout(spacing: 6, lineSpacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Button {
                            tags.removeAll { $0 == tag }
                        } label: {
                            HStack(spacing: 4) {
                                Text(tag)
                                Image(systemName: "xmark")
                                    .font(.caption2.weight(.semibold))
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.fill.tertiary, in: .capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Supprimer le mot-clé \(tag)")
                        .accessibilityIdentifier("remove-tag-\(tag)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            TextField(placeholder, text: $draft)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit(commitDraft)
                .accessibilityIdentifier("tag-input-field")
        }
        .animation(.snappy, value: tags)
        // Leaving the form with a half-typed keyword should not lose it.
        .onDisappear(perform: commitDraft)
    }

    private func commitDraft() {
        let tag = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        draft = ""
        guard !tag.isEmpty else { return }
        guard !tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) else { return }
        tags.append(tag)
    }
}

#Preview("Avec mots-clés") {
    @Previewable @State var tags = ["cumin", "paprika", "épice"]
    return Form {
        Section("Mots-clés") {
            TagField(tags: $tags)
        }
    }
}

#Preview("Vide") {
    @Previewable @State var tags: [String] = []
    return Form {
        Section("Mots-clés") {
            TagField(tags: $tags)
        }
    }
}
