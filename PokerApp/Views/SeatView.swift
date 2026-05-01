import SwiftUI

struct SeatView: View {
    let seat: Seat
    let isDealer: Bool
    let onTap: () -> Void
    let onAdvanceDealer: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                VStack(spacing: 2) {
                    if seat.variant == .flagged {
                        Circle()
                            .fill(Color.appRed)
                            .frame(width: 5, height: 5)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 4)
                    }

                    Text(seat.isEmpty ? "+" : (seat.name.isEmpty ? "Seat" : seat.name))
                        .font(.system(size: seat.isEmpty ? 14 : 8.5, weight: seat.isEmpty ? .light : .semibold))
                        .foregroundColor(nameColor)
                        .lineLimit(1)

                    if !seat.isEmpty && !seat.isHero && !seat.stack.isEmpty {
                        Text(seat.stack)
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.appText2)
                    }

                    if !seat.isEmpty {
                        Text(seat.pos)
                            .font(.system(size: 6.5))
                            .foregroundColor(.appText3)
                    }
                }
                .frame(width: 58, height: 44)
                .background(bgColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, style: seat.isEmpty ? StrokeStyle(lineWidth: 1, dash: [4]) : StrokeStyle(lineWidth: 1))
                )
                .shadow(color: glowColor, radius: 6)
                .opacity(seat.variant == .folded ? 0.3 : 1)
            }
            .buttonStyle(ScaleButtonStyle())

            if isDealer {
                Button(action: onAdvanceDealer) {
                    Text("D")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(Color(hex: "1a1200"))
                        .frame(width: 16, height: 16)
                        .background(Color.gold)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "a08020"), lineWidth: 1.5))
                        .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                }
                .offset(x: 6, y: -6)
            }
        }
    }

    private var bgColor: Color {
        switch seat.variant {
        case .hero:   return Color.accent.opacity(0.15)
        case .empty:  return Color.white.opacity(0.03)
        default:      return Color(hex: "0f1912").opacity(0.85)
        }
    }

    private var borderColor: Color {
        switch seat.variant {
        case .hero:    return Color.accent.opacity(0.4)
        case .flagged: return Color.appRed.opacity(0.5)
        case .acted:   return Color.white.opacity(0.06)
        case .empty:   return Color.white.opacity(0.28)
        default:       return Color.white.opacity(0.1)
        }
    }

    private var glowColor: Color {
        switch seat.variant {
        case .hero:    return Color.accent.opacity(0.2)
        case .flagged: return Color.appRed.opacity(0.2)
        default:       return .clear
        }
    }

    private var nameColor: Color {
        switch seat.variant {
        case .hero:  return Color(hex: "c4b8ff")
        case .empty: return Color.white.opacity(0.35)
        default:     return .appText
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
