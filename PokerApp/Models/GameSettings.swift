import Foundation

struct GameSettings {
    var sb: String = "1"
    var bb: String = "2"
    var format: String = "Cash"
    var players: String = "6"
    var ante: String = "None"
    var buyin: String = ""
    var straddle: Bool = false
    var bombPot: Bool = false

    var playerCount: Int { Int(players) ?? 6 }
    var bbValue: Double { Double(bb) ?? 2 }
}
