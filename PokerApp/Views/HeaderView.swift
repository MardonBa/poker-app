import SwiftUI

struct HeaderView: View {
    @Bindable var state: GameState
    @State private var showResetConfirm = false

    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                guard state.settings != nil else { return }
                state.editingSession = true
            }) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(state.settings.map { "$\($0.sb)/$\($0.bb) \($0.format)" } ?? "Set up game")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.appText)
                    if state.settings != nil {
                        Text("tap to edit")
                            .font(.system(size: 10))
                            .foregroundColor(.appText3)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // P&L
            if let s = state.settings, !s.buyin.isEmpty {
                Text("+$43")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appGreen)
            } else {
                Text("no buy-in")
                    .font(.system(size: 10))
                    .foregroundColor(.appText3)
            }

            HStack(spacing: 8) {
                if state.settings != nil {
                    Text("✎")
                        .font(.system(size: 10))
                        .foregroundColor(.appText3)
                }

                Button("Reset") {
                    showResetConfirm = true
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "f0a0a0"))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.appRed.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.appRed.opacity(0.25), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.appBg.opacity(0.95))
        .overlay(Divider().background(Color.border), alignment: .bottom)
        .alert("Reset session?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) { state.reset() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears all players, history, and hand data.")
        }
    }
}
