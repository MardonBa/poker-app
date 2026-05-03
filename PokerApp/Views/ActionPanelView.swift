import SwiftUI

struct ActionPanelView: View {
    @Bindable var state: GameState

    // Live offset so the panel follows the finger during drag
    @GestureState private var handleDrag: CGFloat = 0
    @GestureState private var bodyDrag: CGFloat = 0

    private var liveOffset: CGFloat {
        let combined = handleDrag + bodyDrag
        return state.panelOpen
            ? max(0, min(100, combined))    // expanded → can only sink down
            : min(0, max(-100, combined))   // collapsed → can only rise up
    }

    var body: some View {
        VStack(spacing: 0) {
            HoleCardsRowView(state: state)

            // Handle — full-width tap + drag target
            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { toggle() }
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .updating($handleDrag) { value, drag, _ in drag = value.translation.height }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height
                            if velocity < -60, !state.panelOpen { expand() }
                            else if velocity > 60, state.panelOpen { collapse() }
                        }
                )

            if state.panelOpen {
                FullPanelView(state: state)
            } else if state.adviceCollapsed, let adv = state.advice, !adv.loading {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.accent)
                        .frame(width: 8, height: 8)
                        .shadow(color: Color.accent.opacity(0.5), radius: 4)
                    Text("Advice ready")
                        .font(.system(size: 12))
                        .foregroundColor(.appText2)
                    Spacer()
                    Button("Show ↑") { expand() }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 12)
            } else {
                MiniBarView(state: state)
            }
        }
        .offset(y: liveOffset)
        .background(Color.appBg2)
        .overlay(Divider().background(Color.border), alignment: .top)
        // When collapsed, the entire panel body is a swipe-up target
        .if(!state.panelOpen) { v in
            v.gesture(
                DragGesture(minimumDistance: 8)
                    .updating($bodyDrag) { value, drag, _ in drag = value.translation.height }
                    .onEnded { value in
                        guard value.predictedEndTranslation.height < -60 else { return }
                        expand()
                    }
            )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.78), value: state.panelOpen)
    }

    // MARK: - Actions

    private func expand() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            state.panelOpen = true
        }
    }

    private func collapse() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            state.panelOpen = false
            if let adv = state.advice, !adv.loading {
                state.adviceCollapsed = true
            }
        }
    }

    private func toggle() {
        if state.panelOpen { collapse() } else { expand() }
    }
}

private struct MiniBarView: View {
    @Bindable var state: GameState

    var body: some View {
        HStack(spacing: 10) {
            MiniStat(label: "Pot", value: state.pot.isEmpty ? "—" : "$\(state.pot)")
            Rectangle().fill(Color.border).frame(width: 1, height: 30)
            MiniStat(label: "Facing", value: facingText)
            Rectangle().fill(Color.border).frame(width: 1, height: 30)
            MiniStat(label: "Odds", value: state.potOdds)
            Spacer()
            Button("Advice ↑") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                    state.panelOpen = true
                }
            }
            .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }

    private var facingText: String {
        switch state.facing {
        case .nothing: return "Nothing"
        case .call:    return "Call $\(state.facingAmt.isEmpty ? "?" : state.facingAmt)"
        case .raise:   return "Raise $\(state.facingAmt.isEmpty ? "?" : state.facingAmt)"
        }
    }
}

private struct MiniStat: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9)).foregroundColor(.appText3)
            Text(value).font(.system(size: 14, weight: .semibold, design: .monospaced)).foregroundColor(.appText)
        }
    }
}

private struct FullPanelView: View {
    @Bindable var state: GameState

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Pot + stack
                HStack(spacing: 8) {
                    LabeledInput(label: "Pot size", placeholder: "$0", text: $state.pot)
                    LabeledInput(label: "Your stack", placeholder: "$200", text: $state.myStack)
                }

                // Facing
                VStack(alignment: .leading, spacing: 4) {
                    Text("What you're facing")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.appText3)
                    HStack(spacing: 6) {
                        FacingButton(label: "Nothing", val: .nothing, state: state)
                        FacingButton(label: "Call", val: .call, state: state)
                        FacingButton(label: "Raise", val: .raise, state: state)
                    }
                }

                // Action before + run it
                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Action before you")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.appText3)
                        TextField("e.g. \"two folds, one limp\"", text: $state.actionBefore)
                            .font(.system(size: 12))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(Color.appBg3)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
                            .foregroundColor(.appText)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Run it")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.appText3)
                        HStack(spacing: 4) {
                            ForEach([1,2,3], id: \.self) { n in
                                Button("\(n)×") {
                                    state.runIt = n
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(state.runIt == n ? Color(hex: "c4b8ff") : .appText2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(state.runIt == n ? Color.accent.opacity(0.15) : Color.appBg3)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(
                                    state.runIt == n ? Color.accent.opacity(0.4) : Color.border2, lineWidth: 1
                                ))
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Calc row
                CalcRowView(state: state)

                // Advice
                AdviceSection(state: state)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 16)
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
}

private struct FacingButton: View {
    let label: String
    let val: FacingOption
    @Bindable var state: GameState

    var active: Bool { state.facing == val }

    var body: some View {
        VStack(spacing: 3) {
            Text(label).font(.system(size: 10))
            if val != .nothing {
                if active {
                    TextField("$__", text: $state.facingAmt)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "e0d8ff"))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .frame(width: 52)
                } else {
                    Text("$__")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.appText3)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .foregroundColor(active ? Color(hex: "c4b8ff") : .appText2)
        .background(active ? Color.accent.opacity(0.15) : Color.appBg3)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(
            active ? Color.accent.opacity(0.4) : Color.border2, lineWidth: 1
        ))
        .onTapGesture {
            state.facing = val
            state.tooltip = nil
        }
    }
}

private struct CalcRowView: View {
    @Bindable var state: GameState

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                CalcItem(label: "Pot odds", value: state.potOdds, tip: "what's this?", active: state.tooltip == .odds) {
                    state.tooltip = state.tooltip == .odds ? nil : .odds
                }
                Divider().background(Color.border).frame(width: 1)
                CalcItem(label: "Eff. stack", value: state.effStack, tip: "what's this?", active: state.tooltip == .stack) {
                    state.tooltip = state.tooltip == .stack ? nil : .stack
                }
                Divider().background(Color.border).frame(width: 1)
                CalcItem(label: "SPR", value: state.spr, tip: "what's this?", active: state.tooltip == .spr) {
                    state.tooltip = state.tooltip == .spr ? nil : .spr
                }
            }
            .background(Color.appBg3)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border, lineWidth: 1))

            if let tip = state.tooltip {
                Text(tooltipText(tip))
                    .font(.system(size: 11))
                    .foregroundColor(.appText2)
                    .lineSpacing(3)
                    .padding(10)
                    .background(Color.appBg3)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func tooltipText(_ t: TooltipTarget) -> String {
        let odds = state.potOdds
        let pct = state.faceNum > 0 ? Int(100.0 / ((Double(odds.dropLast(2)) ?? 0) + 1)) : 0
        switch t {
        case .odds:
            return "Pot odds = ratio of what you need to call vs. the total pot. \(odds) means you need to win roughly \(pct)% of the time to break even."
        case .stack:
            return "Effective stack in big blinds — the most useful way to measure stack depth. Deep stacks (100bb+) favor implied odds and speculative hands. Short stacks (< 30bb) call for more aggressive, all-in-or-fold play."
        case .spr:
            return "Stack-to-pot ratio: your remaining stack divided by the pot. Low SPR (< 2) means you're already committed to the pot. High SPR (> 4) means there's plenty of room to maneuver post-flop."
        }
    }
}

private struct CalcItem: View {
    let label: String
    let value: String
    let tip: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 8))
                    .foregroundColor(.appText3)
                    .tracking(1)
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.appText)
                Text(tip)
                    .font(.system(size: 8))
                    .foregroundColor(.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
        }
        .buttonStyle(.plain)
        .background(active ? Color.white.opacity(0.03) : Color.clear)
    }
}

private struct AdviceSection: View {
    @Bindable var state: GameState

    var body: some View {
        if let adv = state.advice {
            VStack(spacing: 8) {
                if adv.loading {
                    HStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Thinking…")
                            .font(.system(size: 12))
                            .foregroundColor(.appText2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(adv.text)
                        .font(.system(size: 13))
                        .foregroundColor(.appText)
                        .lineSpacing(4)

                    if !state.adviceWhyShown {
                        Button("why? ▾") {
                            state.adviceWhyShown = true
                            guard state.adviceExpanded.isEmpty else { return }
                            Task {
                                state.adviceExpandedLoading = true
                                do {
                                    state.adviceExpanded = try await ClaudeService.complete(
                                        ClaudeService.whyPrompt(advice: adv.text)
                                    )
                                } catch {
                                    state.adviceExpanded = "Couldn't load the explanation."
                                }
                                state.adviceExpandedLoading = false
                            }
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.accent)
                    } else if state.adviceExpandedLoading {
                        HStack(spacing: 8) {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .appText3)).scaleEffect(0.6)
                            Text("Loading…").font(.system(size: 10)).foregroundColor(.appText3)
                        }
                    } else if !state.adviceExpanded.isEmpty {
                        Text(state.adviceExpanded)
                            .font(.system(size: 11))
                            .foregroundColor(.appText2)
                            .lineSpacing(3)
                            .padding(.top, 8)
                            .overlay(Divider().background(Color.border), alignment: .top)
                            .transition(.opacity)
                    }

                    HStack(spacing: 8) {
                        Button("Dismiss") {
                            state.advice = nil
                            state.adviceWhyShown = false
                            state.adviceExpanded = ""
                            state.adviceCollapsed = false
                            state.panelOpen = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .font(.system(size: 12))
                        .foregroundColor(.appText2)
                        .background(Color.appBg3)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
                        .buttonStyle(.plain)

                        Button("New hand →") {
                            state.newHand()
                        }
                        .frame(maxWidth: .infinity * 2)
                        .padding(.vertical, 9)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "c4b8ff"))
                        .background(Color.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.accent.opacity(0.3), lineWidth: 1))
                        .buttonStyle(.plain)
                    }

                    Button("↓ collapse to table") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                            state.panelOpen = false
                            state.adviceCollapsed = true
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.appText3)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(14)
            .background(Color.appBg3)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accent.opacity(0.2), lineWidth: 1))
        } else {
            Button(action: getAdvice) {
                Text("Get advice →")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    private func getAdvice() {
        state.advice = AdviceState(text: "", loading: true)
        state.adviceWhyShown = false
        state.adviceExpanded = ""
        Task {
            do {
                let text = try await ClaudeService.complete(ClaudeService.advicePrompt(state: state))
                state.advice = AdviceState(text: text, loading: false)
            } catch {
                state.advice = AdviceState(text: "Couldn't reach the advisor right now. Check your connection and try again.", loading: false)
            }
        }
    }
}

private struct LabeledInput: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 10, weight: .medium)).foregroundColor(.appText3)
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.appText)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.appBg3)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }
}

extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}
