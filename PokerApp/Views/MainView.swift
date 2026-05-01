import SwiftUI

struct MainView: View {
    @State private var state = GameState()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.appBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    HeaderView(state: state)

                    // Table area
                    Spacer(minLength: 0)
                    HStack {
                        Spacer()
                        TableView(state: state)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    Spacer(minLength: 0)

                    // Hole cards row
                    HoleCardsRowView(state: state)

                    // Action panel
                    ActionPanelView(state: state)
                }

                // Overlays
                if let target = state.pickerTarget {
                    CardPickerView(
                        used: state.usedCards,
                        context: target.label,
                        onPick: { card in state.pickCard(card) },
                        onClose: { state.pickerTarget = nil }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(20)
                }

                if let seatId = state.openSeatId,
                   let seat = state.seats.first(where: { $0.id == seatId }) {
                    OpponentSheetView(seat: seat, onClose: { updated in
                        state.updateSeat(updated)
                        state.openSeatId = nil
                    }, globalState: state)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(20)
                }

                if state.settings == nil {
                    SessionModalView(existing: nil, onSave: { s in
                        state.startSession(s)
                    }, onClose: nil)
                    .transition(.opacity)
                    .zIndex(30)
                }

                if state.editingSession {
                    SessionModalView(existing: state.settings, onSave: { s in
                        state.saveSession(s)
                    }, onClose: {
                        state.editingSession = false
                    })
                    .transition(.opacity)
                    .zIndex(30)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: state.pickerTarget != nil)
            .animation(.easeInOut(duration: 0.2), value: state.openSeatId != nil)
            .animation(.easeInOut(duration: 0.2), value: state.settings == nil)
            .animation(.easeInOut(duration: 0.2), value: state.editingSession)
        }
    }
}
