import SwiftUI

extension Font {
    static func dmSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("DMSans-Regular", size: size).weight(weight)
    }
    static func dmMono(_ size: CGFloat) -> Font {
        .custom("DMMono-Regular", size: size)
    }
}
