import Foundation

struct AdviceState {
    var text: String
    var loading: Bool
}

enum FacingOption: String {
    case nothing = "nothing"
    case call    = "call"
    case raise   = "raise"
}

enum TooltipTarget {
    case odds, stack, spr
}
