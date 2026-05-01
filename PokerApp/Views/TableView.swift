import SwiftUI

struct TableView: View {
    @Bindable var state: GameState

    var body: some View {
        let size = state.tableSize

        ZStack {
            // Felt
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "1f5a36"), Color(hex: "1a4a2e"), Color(hex: "163d25")],
                        center: UnitPoint(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: max(size.width, size.height)
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .stroke(Color(hex: "0f2a1a"), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.5), radius: 20, y: 8)

            // Center content
            TableCenterView(state: state)

            // Seats
            ForEach(Array(state.seats.enumerated()), id: \.element.id) { i, seat in
                let pos = seatPos(i, total: state.seats.count, size: size)
                SeatView(
                    seat: seat,
                    isDealer: i == state.dealerIdx,
                    onTap: { state.openSeatId = seat.id },
                    onAdvanceDealer: { state.advanceDealer() }
                )
                .position(x: pos.x + 29, y: pos.y + 22)
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

private struct TableCenterView: View {
    @Bindable var state: GameState
    @State private var potEditing = false
    @FocusState private var potFocused: Bool

    var body: some View {
        VStack(spacing: 6) {
            // Community cards
            HStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { i in
                    if let card = state.boardCards[i] {
                        MiniCardView(card: card)
                            .onTapGesture { state.pickerTarget = .board(i) }
                    } else {
                        MiniCardView(card: nil)
                            .onTapGesture { state.pickerTarget = .board(i) }
                    }
                }
            }

            // Pot
            if potEditing {
                TextField("0", text: $state.pot)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .frame(width: 64)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white.opacity(0.22), lineWidth: 1))
                    .focused($potFocused)
                    .onSubmit { potEditing = false }
            } else {
                HStack(spacing: 4) {
                    Text("POT")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.4))
                        .tracking(2)
                    Text(state.pot.isEmpty ? "tap to set" : "$\(state.pot)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(state.pot.isEmpty ? Color.white.opacity(0.22) : Color.white.opacity(0.7))
                        .underline(true, color: Color.white.opacity(0.2))
                }
                .onTapGesture {
                    potEditing = true
                    potFocused = true
                }
            }

            // Shown cards ghost
            if !state.shownCards.isEmpty {
                HStack(spacing: 3) {
                    ForEach(state.shownCards, id: \.id) { c in
                        Text("\(c.rank)\(c.suit)")
                            .font(.system(size: 6))
                            .foregroundColor(c.isRed ? Color(hex: "f99999") : Color.white.opacity(0.3))
                            .frame(width: 16, height: 22)
                            .background(Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [3])))
                    }
                }
            }

            // Show card button
            Button("+ card was shown") {
                state.pickerTarget = .shown
            }
            .font(.system(size: 9, weight: .medium))
            .foregroundColor(Color.white.opacity(0.65))
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
    }
}

struct MiniCardView: View {
    let card: PlayingCard?

    var body: some View {
        Group {
            if let c = card {
                VStack(spacing: 0) {
                    Text(c.rank).font(.system(size: 11, weight: .bold))
                    Text(c.suit).font(.system(size: 9))
                }
                .foregroundColor(c.isRed ? Color(hex: "c0392b") : Color(hex: "1a1a1a"))
                .background(Color.cardBg)
            } else {
                Text("+")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.15))
                    .background(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.12), style: StrokeStyle(lineWidth: 1.5, dash: [3])))
            }
        }
        .frame(width: 28, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
    }
}
