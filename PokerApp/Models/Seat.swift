import Foundation

enum SeatVariant: String, Codable {
    case hero, normal, flagged, folded, acted, empty
}

struct Seat: Identifiable {
    let id: Int
    var name: String
    var stack: String
    var pos: String
    var variant: SeatVariant
    var isHero: Bool
    var isEmpty: Bool
    var notes: String = ""
    var shownCards: [PlayingCard] = []
    var streetActions: [String: String] = [:]
    var streetAmounts: [String: String] = [:]
    var showVoluntary: Bool = false
}

let posMap2 = ["BTN","BB"]
let posMap6 = ["UTG","MP","CO","BTN","SB","BB"]
let posMap9 = ["UTG","UTG+1","MP","MP+1","HJ","CO","BTN","SB","BB"]

let posInfo: [String: String] = [
    "UTG": "First to act",
    "UTG+1": "Under the gun + 1",
    "MP": "Middle position",
    "MP+1": "Middle position + 1",
    "HJ": "Hijack",
    "CO": "Cutoff",
    "BTN": "Dealer — acts last",
    "SB": "Small blind",
    "BB": "Big blind",
]

func makeSeats(_ count: Int) -> [Seat] {
    let map = count == 2 ? posMap2 : count == 9 ? posMap9 : posMap6
    let heroIdx = count == 2 ? 0 : count == 9 ? 6 : 3
    return (0..<count).map { i in
        let isHero = i == heroIdx
        return Seat(
            id: i + 1,
            name: isHero ? "YOU" : "",
            stack: isHero ? "$200" : "",
            pos: i < map.count ? map[i] : "Seat \(i+1)",
            variant: isHero ? .hero : .empty,
            isHero: isHero,
            isEmpty: !isHero
        )
    }
}

func tableDims(_ count: Int) -> CGSize {
    if count <= 2 { return CGSize(width: 300, height: 220) }
    if count <= 6 { return CGSize(width: 350, height: 240) }
    return CGSize(width: 356, height: 260)
}

func seatPos(_ i: Int, total: Int, size: CGSize) -> CGPoint {
    let cx = size.width / 2, cy = size.height / 2
    let padX: CGFloat = total >= 9 ? 8 : total >= 6 ? 10 : 14
    let padY: CGFloat = total >= 9 ? 6 : total >= 6 ? 8 : 14
    let rx = size.width / 2 - padX - 29
    let ry = size.height / 2 - padY - 22
    let angle = (2 * .pi / CGFloat(total)) * CGFloat(i) - .pi / 2
    return CGPoint(x: cx + rx * cos(angle) - 29, y: cy + ry * sin(angle) - 22)
}
