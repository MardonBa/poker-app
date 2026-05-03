import SwiftUI

struct OpponentSheetView: View {
    let seat: Seat
    let onClose: (Seat) -> Void
    @Bindable var globalState: GameState

    @State private var name: String
    @State private var stack: String
    @State private var notes: String
    @State private var shownCards: [PlayingCard]
    @State private var showVoluntary: Bool
    @State private var streetActions: [String: String]
    @State private var streetAmounts: [String: String]
    @State private var showCardPicker = false

    private let streets = ["Pre","Flop","Turn","River"]

    init(seat: Seat, onClose: @escaping (Seat) -> Void, globalState: GameState) {
        self.seat = seat
        self.onClose = onClose
        self.globalState = globalState
        _name          = State(initialValue: seat.name)
        _stack         = State(initialValue: seat.stack)
        _notes         = State(initialValue: seat.notes)
        _shownCards    = State(initialValue: seat.shownCards)
        _showVoluntary = State(initialValue: seat.showVoluntary)
        _streetActions = State(initialValue: seat.streetActions)
        _streetAmounts = State(initialValue: seat.streetAmounts)
    }

    private func save() {
        var updated = seat
        updated.name = name; updated.stack = stack; updated.notes = notes
        updated.shownCards = shownCards; updated.showVoluntary = showVoluntary
        updated.streetActions = streetActions; updated.streetAmounts = streetAmounts
        onClose(updated)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.65).ignoresSafeArea()
                .onTapGesture { save() }

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)

                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(seat.isHero ? "Your seat" : (name.isEmpty ? "Unknown player" : name))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.appText)
                        Text("\(seat.pos) · Stack: \(stack.isEmpty ? "—" : stack)")
                            .font(.system(size: 11))
                            .foregroundColor(.appText2)
                    }
                    Spacer()
                    Button(action: save) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.appText2)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.07))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .overlay(Divider(), alignment: .bottom)

                ScrollView {
                    VStack(spacing: 14) {

                        // Name + Stack
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel("Name (optional)")
                                TextField("Seat name", text: $name)
                                    .textFieldStyle(DarkFieldStyle())
                            }.frame(maxWidth: .infinity)

                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel("Stack")
                                TextField("$__", text: $stack)
                                    .textFieldStyle(DarkFieldStyle())
                                    .keyboardType(.decimalPad)
                            }.frame(width: 90)
                        }

                        // Tendencies (non-hero, non-empty)
                        if !seat.isEmpty && !seat.isHero {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("TENDENCIES · 8 HANDS")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.appText3)
                                    .tracking(1)
                                Text("Loose-aggressive. Bets bigger when strong — avg 80% pot with made hands vs 45% with draws. Plays tighter from early position.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appText2)
                                    .lineSpacing(3)
                                HStack(spacing: 5) {
                                    ForEach(["Loose","Aggressive","Overbet strong","Position aware"], id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 10))
                                            .foregroundColor(.appText2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                    }
                                }
                                .flexibleWidth()
                            }
                            .padding(12)
                            .background(Color.appBg3)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Pattern flag
                        if seat.variant == .flagged {
                            HStack(alignment: .top, spacing: 10) {
                                Circle().fill(Color.appRed).frame(width: 8, height: 8).padding(.top, 3)
                                Text("**Pattern flag:** large bet on flop — more aggressive than their usual baseline. May indicate a strong made hand or a bluff.")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "f0a0a0"))
                                    .lineSpacing(3)
                            }
                            .padding(12)
                            .background(Color.appRed.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appRed.opacity(0.2), lineWidth: 1))
                        }

                        // Action logger
                        if !seat.isEmpty && !seat.isHero {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionLabel("This hand")
                                VStack(spacing: 0) {
                                    ForEach(streets, id: \.self) { street in
                                        StreetRow(
                                            street: street,
                                            action: Binding(
                                                get: { streetActions[street] },
                                                set: { streetActions[street] = $0 }
                                            ),
                                            amount: Binding(
                                                get: { streetAmounts[street] ?? "" },
                                                set: { streetAmounts[street] = $0 }
                                            )
                                        )
                                        if street != streets.last {
                                            Divider().background(Color.border)
                                        }
                                    }
                                }
                            }
                        }

                        // Shown cards
                        if !seat.isEmpty && !seat.isHero {
                            VStack(alignment: .leading, spacing: 8) {
                                if shownCards.isEmpty {
                                    Button("+ Showed cards at showdown") {
                                        showCardPicker = true
                                    }
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.appText2)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Color.appBg3)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.border2, lineWidth: 1))
                                } else {
                                    HStack(spacing: 6) {
                                        Text("SHOWED:")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.appText3)
                                            .tracking(1)
                                        ForEach(shownCards, id: \.id) { c in
                                            MiniCardView(card: c)
                                        }
                                        if shownCards.count < 2 {
                                            Button("+") { showCardPicker = true }
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.appText2)
                                                .frame(width: CardSize.addCardWidth, height: CardSize.addCardHeight)
                                                .background(Color.appBg3)
                                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                        }
                                    }
                                    Text("Bet big on flop with a pair — consistent with their aggressive tendencies.")
                                        .font(.system(size: 10))
                                        .italic()
                                        .foregroundColor(.appText2)
                                }

                                // Showed voluntarily
                                HStack(spacing: 7) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                            .frame(width: 16, height: 16)
                                        if showVoluntary {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .onTapGesture { showVoluntary.toggle() }

                                    Text("Showed voluntarily (didn't have to)")
                                        .font(.system(size: 11))
                                        .foregroundColor(.appText2)
                                }
                            }
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 4) {
                            FieldLabel("Notes")
                            TextEditor(text: $notes)
                                .frame(minHeight: 60)
                                .font(.system(size: 12))
                                .foregroundColor(.appText)
                                .padding(9)
                                .background(Color.appBg3)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
                                .scrollContentBackground(.hidden)
                        }

                        // Management buttons
                        if !seat.isHero {
                            HStack(spacing: 8) {
                                if seat.isEmpty {
                                    Button("Add player") {
                                        var updated = seat
                                        updated.isEmpty = false
                                        updated.variant = .normal
                                        updated.name = name.isEmpty ? "Seat" : name
                                        updated.stack = stack
                                        onClose(updated)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(hex: "c4b8ff"))
                                    .background(Color.accent.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.accent.opacity(0.4), lineWidth: 1))
                                } else {
                                    Button("Mark seat empty") {
                                        var updated = seat
                                        updated.isEmpty = true; updated.variant = .empty
                                        updated.name = ""; updated.stack = ""; updated.notes = ""
                                        updated.shownCards = []; updated.streetActions = [:]
                                        onClose(updated)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.appText2)
                                    .background(Color.appBg3)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.border2, lineWidth: 1))

                                    Button("Remove player") {
                                        var updated = seat
                                        updated.isEmpty = true; updated.variant = .empty
                                        updated.name = ""; updated.stack = ""; updated.notes = ""
                                        updated.shownCards = []; updated.streetActions = [:]
                                        onClose(updated)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.appRed)
                                    .background(Color.appBg3)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.appRed.opacity(0.3), lineWidth: 1))
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.immediately)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { dismissKeyboard() }
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
            .background(Color.appBg2)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxHeight: UIScreen.main.bounds.height * 0.88)

            if showCardPicker {
                CardPickerView(
                    used: Set(shownCards.map { $0.id }).union(globalState.usedCards),
                    context: "Showdown card",
                    onPick: { card in
                        shownCards.append(card)
                        showCardPicker = false
                    },
                    onClose: { showCardPicker = false }
                )
            }
        }
        .ignoresSafeArea()
    }
}

private struct StreetRow: View {
    let street: String
    @Binding var action: String?
    @Binding var amount: String

    private let actions = ["Fold","Call","Raise"]

    var body: some View {
        HStack(spacing: 6) {
            Text(street.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.appText3)
                .tracking(1)
                .frame(width: 30, alignment: .leading)

            HStack(spacing: 4) {
                ForEach(actions, id: \.self) { act in
                    let isSel = action == act
                    Button(act) {
                        action = isSel ? nil : act
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSel ? (act == "Fold" ? Color(hex: "f0a0a0") : Color(hex: "c4b8ff")) : .appText2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isSel ? (act == "Fold" ? Color.appRed.opacity(0.12) : Color.accent.opacity(0.15)) : Color.appBg3)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                        isSel ? (act == "Fold" ? Color.appRed.opacity(0.3) : Color.accent.opacity(0.4)) : Color.border2,
                        lineWidth: 1
                    ))
                    .buttonStyle(.plain)
                }

                if action == "Raise" {
                    TextField("$__", text: $amount)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.appText)
                        .frame(width: 48)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.appBg3)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.border2, lineWidth: 1))
                        .keyboardType(.decimalPad)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Helpers

struct FieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.appText3)
    }
}

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.appText3)
            .tracking(1)
    }
}

struct DarkFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .font(.system(size: 14, design: .monospaced).weight(.medium))
            .foregroundColor(.appText)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.appBg3)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
    }
}

extension View {
    func flexibleWidth() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
    }
}
