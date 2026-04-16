import SwiftUI

struct ReminderEditSheet: View {
    let initial: Fields
    let onSave: (Fields) async throws -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date
    @State private var isRecurring: Bool
    @State private var frequency: ReminderFrequency
    @State private var customIntervalDays: Int
    @State private var isSaving = false
    @State private var saveError: String?

    init(initial: Fields, onSave: @escaping (Fields) async throws -> Void, onCancel: @escaping () -> Void) {
        self.initial = initial
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: initial.title)
        _notes = State(initialValue: initial.notes)
        _dueDate = State(initialValue: initial.dueDate)
        _isRecurring = State(initialValue: initial.frequency != nil)
        _frequency = State(initialValue: initial.frequency ?? .quarterly)
        _customIntervalDays = State(initialValue: initial.customIntervalDays ?? 30)
    }

    var body: some View {
        Form {
            Section("Titre") {
                TextField("Changer la pile, détartrer…", text: $title)
                    .textInputAutocapitalization(.sentences)
            }

            Section("Date de rappel") {
                DatePicker("Échéance", selection: $dueDate)
                    .labelsHidden()
            }

            Section("Répétition") {
                Toggle("Récurrent", isOn: $isRecurring.animation())
                if isRecurring {
                    Picker("Fréquence", selection: $frequency) {
                        ForEach(ReminderFrequency.allCases) { freq in
                            Text(freq.label).tag(freq)
                        }
                    }
                    if frequency == .customDays {
                        Stepper("Tous les \(customIntervalDays) jours", value: $customIntervalDays, in: 1...3650)
                    }
                }
            }

            Section("Notes") {
                TextField("Notice, consignes…", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", systemImage: "xmark") { onCancel() }
                    .labelStyle(.iconOnly)
                    .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Enregistrer", systemImage: "checkmark") {
                        Task { await save() }
                    }
                    .labelStyle(.iconOnly)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    private func save() async {
        isSaving = true
        let fields = Fields(
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            dueDate: dueDate,
            frequency: isRecurring ? frequency : nil,
            customIntervalDays: isRecurring && frequency == .customDays ? customIntervalDays : nil
        )
        do {
            try await onSave(fields)
        } catch {
            saveError = reportError(error)
        }
        isSaving = false
    }
}

extension ReminderEditSheet {
    struct Fields: Sendable {
        var title: String
        var notes: String
        var dueDate: Date
        var frequency: ReminderFrequency?
        var customIntervalDays: Int?

        init(
            title: String = "",
            notes: String = "",
            dueDate: Date = Date(timeIntervalSinceNow: 86_400),
            frequency: ReminderFrequency? = nil,
            customIntervalDays: Int? = nil
        ) {
            self.title = title
            self.notes = notes
            self.dueDate = dueDate
            self.frequency = frequency
            self.customIntervalDays = customIntervalDays
        }

        init(from reminder: Reminder) {
            self.init(
                title: reminder.title,
                notes: reminder.notes,
                dueDate: reminder.dueDate,
                frequency: reminder.frequency,
                customIntervalDays: reminder.customIntervalDays
            )
        }
    }
}

#Preview("New") {
    NavigationStack {
        ReminderEditSheet(
            initial: .init(),
            onSave: { _ in },
            onCancel: {}
        )
        .navigationTitle("Nouveau rappel")
    }
}
