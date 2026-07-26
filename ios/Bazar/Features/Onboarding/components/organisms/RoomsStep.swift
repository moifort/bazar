import SwiftUI

struct RoomsStep: View {
    let rooms: [SuggestedRoom]
    @Binding var selected: Set<String>

    var body: some View {
        List(rooms) { room in
            Button {
                toggle(room.name)
            } label: {
                HStack {
                    Text(room.icon)
                    Text(room.name)
                    Spacer()
                    if selected.contains(room.name) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }
            .tint(.primary)
            .accessibilityAddTraits(selected.contains(room.name) ? [.isSelected] : [])
        }
        .listStyle(.plain)
        .accessibilityIdentifier("onboarding-rooms")
    }

    private func toggle(_ name: String) {
        if selected.contains(name) {
            selected.remove(name)
        } else {
            selected.insert(name)
        }
    }
}

#Preview {
    RoomsStep(rooms: SuggestedRooms.all, selected: .constant(SuggestedRooms.preselected))
}
