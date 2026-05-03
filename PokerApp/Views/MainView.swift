import SwiftUI

struct MainView: View {
    @State private var state = GameState()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.appBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    HeaderView(state: state)

                    Spacer(minLength: 0)
                    HStack {
                        Spacer()
                        TableView(state: state)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    Spacer(minLength: 0)

                    ActionPanelView(state: state)
                }

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
            }
            .animation(.easeInOut(duration: 0.2), value: state.pickerTarget != nil)
            .animation(.easeInOut(duration: 0.2), value: state.openSeatId != nil)
            .fullScreenCover(isPresented: Binding(
                get: { state.settings == nil },
                set: { _ in }
            )) {
                SessionModalView(existing: nil, onSave: { s in
                    state.startSession(s)
                }, onClose: nil)
                .interactiveDismissDisabled(true)
            }
            .fullScreenCover(isPresented: Binding(
                get: { state.editingSession },
                set: { state.editingSession = $0 }
            )) {
                SessionModalView(existing: state.settings, onSave: { s in
                    state.saveSession(s)
                }, onClose: {
                    state.editingSession = false
                })
            }
        }
    }
}
