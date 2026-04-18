import SwiftUI

/// Large, tactile replacement for SwiftUI's compact Stepper.
/// Two glass-styled capsule buttons framing the current value.
struct QuantityStepper: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...9999

    var body: some View {
        HStack(spacing: 12) {
            Text("Quantité")
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                guard value > range.lowerBound else { return }
                value -= 1
            } label: {
                Image(systemName: "minus")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.glass)
            .clipShape(.capsule)
            .disabled(value <= range.lowerBound)
            .accessibilityLabel("Diminuer la quantité")

            Text("\(value)")
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .frame(minWidth: 36)
                .contentTransition(.numericText(value: Double(value)))

            Button {
                guard value < range.upperBound else { return }
                value += 1
            } label: {
                Image(systemName: "plus")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.glass)
            .clipShape(.capsule)
            .disabled(value >= range.upperBound)
            .accessibilityLabel("Augmenter la quantité")
        }
        .sensoryFeedback(.increase, trigger: value)
        .animation(.snappy, value: value)
    }
}

#Preview("QuantityStepper") {
    @Previewable @State var value = 3
    return QuantityStepper(value: $value)
        .padding()
}
