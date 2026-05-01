import Foundation

struct PlayingCard: Hashable, Identifiable, Codable {
    var id: String { rank + suit }
    let rank: String
    let suit: String
    var isRed: Bool { suit == "♥" || suit == "♦" }

    static let ranks = ["A","2","3","4","5","6","7","8","9","T","J","Q","K"]
    static let suits: [(label: String, sym: String, red: Bool)] = [
        ("♠ Spades",   "♠", false),
        ("♥ Hearts",   "♥", true),
        ("♦ Diamonds", "♦", true),
        ("♣ Clubs",    "♣", false),
    ]
}

enum PickerTarget: Equatable {
    case board(Int)
    case hole(Int)
    case shown
    case opponentShown

    var label: String {
        switch self {
        case .board(let i): return "Board card \(i + 1)"
        case .hole(let i):  return "Your hole card \(i + 1)"
        case .shown:        return "Card was shown"
        case .opponentShown: return "Showdown card"
        }
    }
}
