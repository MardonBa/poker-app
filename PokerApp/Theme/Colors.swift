import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let appBg      = Color(hex: "1c1917")
    static let appBg2     = Color(hex: "231f1c")
    static let appBg3     = Color(hex: "2c2824")
    static let felt       = Color(hex: "1a4a2e")
    static let felt2      = Color(hex: "163d25")
    static let feltBorder = Color(hex: "0f2a1a")
    static let accent     = Color(hex: "7c6af7")
    static let accentDim  = Color(hex: "7c6af7").opacity(0.15)
    static let appText    = Color(hex: "f0ece6")
    static let appText2   = Color(hex: "a09890")
    static let appText3   = Color(hex: "605850")
    static let appRed     = Color(hex: "e05a5a")
    static let appGreen   = Color(hex: "4ade80")
    static let gold       = Color(hex: "d4af37")
    static let cardBg     = Color(hex: "faf9f6")
    static let border     = Color.white.opacity(0.07)
    static let border2    = Color.white.opacity(0.12)
}
