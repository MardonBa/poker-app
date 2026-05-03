import SwiftUI

struct SessionModalView: View {
    let existing: GameSettings?
    let onSave: (GameSettings) -> Void
    let onClose: (() -> Void)?

    @State private var sb: String
    @State private var bb: String
    @State private var format: String
    @State private var players: String
    @State private var ante: String
    @State private var buyin: String
    @State private var straddle: Bool
    @State private var bombPot: Bool
    @State private var showMore: Bool

    private var isEdit: Bool { existing != nil }

    init(existing: GameSettings?, onSave: @escaping (GameSettings) -> Void, onClose: (() -> Void)?) {
        self.existing = existing
        self.onSave = onSave
        self.onClose = onClose
        _sb       = State(initialValue: existing?.sb ?? "1")
        _bb       = State(initialValue: existing?.bb ?? "2")
        _format   = State(initialValue: existing?.format ?? "Cash")
        _players  = State(initialValue: existing?.players ?? "6")
        _ante     = State(initialValue: existing?.ante ?? "None")
        _buyin    = State(initialValue: existing?.buyin ?? "")
        _straddle = State(initialValue: existing?.straddle ?? false)
        _bombPot  = State(initialValue: existing?.bombPot ?? false)
        _showMore = State(initialValue: existing != nil)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isEdit ? "Edit Session" : "New Session")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.appText)
                                    .tracking(-0.5)
                                Text(isEdit ? "Changes apply immediately" : "Set up your game to get started")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appText2)
                            }
                            Spacer()
                            if isEdit {
                                Button(action: { onClose?() }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appText2)
                                        .frame(width: 32, height: 32)
                                        .background(Color.white.opacity(0.07))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.top, 12)

                        // Blinds
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 2) {
                                FieldLabel("Blinds")
                                Text("*").foregroundColor(.appRed).font(.system(size: 10))
                            }
                            HStack(spacing: 8) {
                                TextField("SB", text: $sb)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(DarkFieldStyle())
                                    .frame(width: 90)
                                Text("/")
                                    .font(.system(size: 16))
                                    .foregroundColor(.appText3)
                                TextField("BB", text: $bb)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(DarkFieldStyle())
                                    .frame(width: 90)
                            }
                        }

                        // More options toggle
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showMore.toggle() } }) {
                            HStack(spacing: 4) {
                                Text(showMore ? "▼" : "▶").font(.system(size: 12))
                                Text(showMore ? "Hide options" : "More options").font(.system(size: 11))
                            }
                            .foregroundColor(.appText3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if showMore {
                            VStack(spacing: 18) {
                                VStack(alignment: .leading, spacing: 6) {
                                    FieldLabel("Format")
                                    SegControl(options: ["Cash","Tournament"], selected: $format)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    FieldLabel("Table size")
                                    SegControl(options: ["2","6","9"], labels: ["2 players","6 players","9 players"], selected: $players)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    FieldLabel("Ante structure")
                                    SegControl(options: ["None","Standard","BB ante","Btn ante"], selected: $ante, fontSize: 10)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    FieldLabel("Buy-in (for P&L tracking, optional)")
                                    TextField("$200", text: $buyin)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(DarkFieldStyle())
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    FieldLabel("Special rules")
                                    HStack(spacing: 6) {
                                        ToggleSegBtn(label: "Straddle", active: $straddle)
                                        ToggleSegBtn(label: "Bomb pot", active: $bombPot)
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Button(action: {
                            onSave(GameSettings(sb: sb, bb: bb, format: format, players: players, ante: ante, buyin: buyin, straddle: straddle, bombPot: bombPot))
                        }) {
                            Text(isEdit ? "Save Changes →" : "Start Session →")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { dismissKeyboard() }
                        .font(.system(size: 15, weight: .semibold))
                }
            }
        }
    }
}

struct SegControl: View {
    let options: [String]
    var labels: [String]? = nil
    @Binding var selected: String
    var fontSize: CGFloat = 11

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { opt in
                let lbl = labels?[options.firstIndex(of: opt)!] ?? opt
                Button(action: { selected = opt }) {
                    Text(lbl)
                        .font(.system(size: fontSize, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .foregroundColor(selected == opt ? .appText : .appText2)
                        .background(selected == opt ? Color.appBg2 : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .shadow(color: selected == opt ? .black.opacity(0.3) : .clear, radius: 3, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.appBg3)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ToggleSegBtn: View {
    let label: String
    @Binding var active: Bool

    var body: some View {
        Button(action: { active.toggle() }) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .foregroundColor(active ? .appText : .appText2)
                .background(active ? Color.appBg2 : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .padding(3)
        .background(Color.appBg3)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
