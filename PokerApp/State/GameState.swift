import SwiftUI
import Observation

@Observable
class GameState {
    var settings: GameSettings? = nil
    var editingSession = false
    var seats: [Seat] = makeSeats(6)
    var boardCards: [PlayingCard?] = Array(repeating: nil, count: 5)
    var holeCards: [PlayingCard?] = [nil, nil]
    var shownCards: [PlayingCard] = []
    var heroPos = "BTN"
    var dealerIdx = 3

    var panelOpen = false
    var adviceCollapsed = false
    var pot = ""
    var myStack = "200"
    var facing: FacingOption = .nothing
    var facingAmt = ""
    var actionBefore = ""
    var runIt = 1
    var tooltip: TooltipTarget? = nil
    var advice: AdviceState? = nil
    var adviceWhyShown = false
    var adviceExpanded = ""
    var adviceExpandedLoading = false

    var pickerTarget: PickerTarget? = nil
    var openSeatId: Int? = nil
    var showResetConfirm = false

    // MARK: - Derived

    var potNum: Double { Double(pot) ?? 0 }
    var stackNum: Double { Double(myStack) ?? 0 }
    var faceNum: Double { Double(facingAmt) ?? 0 }

    var potOdds: String {
        guard faceNum > 0 else { return "—" }
        let ratio = (potNum + faceNum) / faceNum
        return String(format: "%.1f:1", ratio)
    }

    var effStack: String {
        guard stackNum > 0, let s = settings else { return "—" }
        let bb = s.bbValue
        return "\(Int((stackNum / bb).rounded()))bb"
    }

    var spr: String {
        guard potNum > 0, stackNum > 0 else { return "—" }
        return String(format: "%.1f", stackNum / potNum)
    }

    var tableSize: CGSize { tableDims(seats.count) }

    var usedCards: Set<String> {
        var s = Set<String>()
        boardCards.compactMap { $0 }.forEach { s.insert($0.id) }
        holeCards.compactMap { $0 }.forEach { s.insert($0.id) }
        shownCards.forEach { s.insert($0.id) }
        return s
    }

    // MARK: - Actions

    func startSession(_ s: GameSettings) {
        settings = s
        editingSession = false
        let count = s.playerCount
        seats = makeSeats(count)
        dealerIdx = seats.firstIndex(where: { $0.pos == "BTN" }) ?? 0
    }

    func saveSession(_ s: GameSettings) {
        let prev = settings?.playerCount ?? 6
        settings = s
        editingSession = false
        if s.playerCount != prev {
            seats = makeSeats(s.playerCount)
            dealerIdx = seats.firstIndex(where: { $0.pos == "BTN" }) ?? 0
        }
    }

    func advanceDealer() {
        dealerIdx = (dealerIdx + 1) % seats.count
    }

    func updateSeat(_ updated: Seat) {
        if let idx = seats.firstIndex(where: { $0.id == updated.id }) {
            seats[idx] = updated
        }
    }

    func pickCard(_ card: PlayingCard) {
        guard let t = pickerTarget else { return }
        switch t {
        case .board(let i):
            boardCards[i] = card
        case .hole(let i):
            holeCards[i] = card
        case .shown:
            shownCards.append(card)
        case .opponentShown:
            break
        }
        pickerTarget = nil
    }

    func newHand() {
        boardCards = Array(repeating: nil, count: 5)
        holeCards = [nil, nil]
        shownCards = []
        pot = ""
        facing = .nothing
        facingAmt = ""
        actionBefore = ""
        runIt = 1
        advice = nil
        adviceWhyShown = false
        adviceExpanded = ""
        adviceExpandedLoading = false
        adviceCollapsed = false
        panelOpen = false
        seats = seats.map { s in
            var copy = s
            copy.streetActions = [:]
            copy.streetAmounts = [:]
            return copy
        }
    }

    func reset() {
        settings = nil
        seats = makeSeats(6)
        dealerIdx = 3
        boardCards = Array(repeating: nil, count: 5)
        holeCards = [nil, nil]
        shownCards = []
        pot = ""; myStack = "200"
        facing = .nothing; facingAmt = ""
        actionBefore = ""; runIt = 1
        advice = nil; adviceWhyShown = false; adviceExpanded = ""
        adviceExpandedLoading = false
        adviceCollapsed = false; panelOpen = false
        heroPos = "BTN"
        tooltip = nil
    }
}
