import SwiftUI

/// The "Abonnement" settings section: the plan in force, what is left of this
/// month's scans, and — on the free plan only — the door to the Premium sheet.
///
/// Premium shows no gauge at all. There is a ceiling behind the scenes, but the
/// subscription is sold as "scan without counting" and a meter would sell the
/// opposite. Primitive-first: it knows nothing of the API types nor of the sheet,
/// only numbers, labels and a callback.
struct QuotaSection: View {
    let isPremium: Bool
    let used: Int
    let limit: Int?
    let renewsOn: Date?
    /// Opens the Premium sheet — the row only exists on the free plan.
    var onUpgrade: () -> Void = {}

    var body: some View {
        Section {
            LabeledContent("Formule") {
                Text(isPremium ? "Premium" : "Gratuite")
                    .foregroundStyle(isPremium ? Color.accentColor : .secondary)
            }
            if let limit {
                QuotaMeterRow(used: used, limit: limit)
            }
            if !isPremium {
                Button(action: onUpgrade) {
                    Label {
                        Text("Découvrir Premium")
                    } icon: {
                        Image(systemName: "crown.fill").foregroundStyle(Color.accentColor)
                    }
                }
                .accessibilityIdentifier("discover-premium-button")
            }
        } header: {
            Text("Abonnement")
        } footer: {
            if isPremium {
                Text("Scannez sans compter : aucune allocation mensuelle à surveiller.")
            } else if let renewsOn {
                Text("Votre compteur repart à zéro le \(Self.renewalLabel(renewsOn)).")
            }
        }
    }

    /// The renewal date is always the 1st of a month, so the day is spelled "1er".
    private static func renewalLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return "1er \(formatter.string(from: date))"
    }
}

/// One meter: how many scans of the month's allowance are gone.
private struct QuotaMeterRow: View {
    let used: Int
    let limit: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Scans ce mois-ci", systemImage: "camera.viewfinder")
                    .font(.subheadline)
                Spacer()
                Text("\(used) / \(limit)")
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(used >= limit ? Color.red : .secondary)
            }
            ProgressView(value: Double(min(used, limit)), total: Double(limit))
                .tint(used >= limit ? .red : .accentColor)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Gratuit") {
    List {
        QuotaSection(
            isPremium: false,
            used: 7,
            limit: 10,
            renewsOn: Date(timeIntervalSince1970: 1_785_888_000)
        )
    }
}

#Preview("Gratuit — épuisé") {
    List {
        QuotaSection(
            isPremium: false,
            used: 10,
            limit: 10,
            renewsOn: Date(timeIntervalSince1970: 1_785_888_000)
        )
    }
}

#Preview("Premium") {
    List {
        QuotaSection(isPremium: true, used: 214, limit: nil, renewsOn: nil)
    }
}
