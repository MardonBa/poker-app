import SwiftUI

struct CardPickerView: View {
    let used: Set<String>
    let context: String
    let onPick: (PlayingCard) -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.65).ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)

                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pick a card")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.appText)
                        Text("for: \(context)")
                            .font(.system(size: 11))
                            .foregroundColor(.appText2)
                    }
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.appText2)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.07))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .overlay(Divider().background(Color.border), alignment: .bottom)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(PlayingCard.suits, id: \.sym) { suit in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suit.label)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.appText3)

                                LazyVGrid(columns: [GridItem(.adaptive(minimum: CardSize.miniWidth), spacing: 3)], spacing: 3) {
                                    ForEach(PlayingCard.ranks, id: \.self) { rank in
                                        let card = PlayingCard(rank: rank, suit: suit.sym)
                                        let isUsed = used.contains(card.id)
                                        PickCardCell(rank: rank, suit: suit.sym, isRed: suit.red, isUsed: isUsed) {
                                            if !isUsed { onPick(card) }
                                        }
                                    }
                                }
                            }
                        }

                        Text("Grayed cards are already in play")
                            .font(.system(size: 10))
                            .italic()
                            .foregroundColor(.appText3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(Color.appBg2)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxHeight: UIScreen.main.bounds.height * 0.75)
        }
        .ignoresSafeArea()
    }
}

private struct PickCardCell: View {
    let rank: String
    let suit: String
    let isRed: Bool
    let isUsed: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(rank).font(.system(size: 11, weight: .bold))
            Text(suit).font(.system(size: 9))
        }
        .foregroundColor(cellFg)
        .frame(width: CardSize.miniWidth, height: CardSize.miniHeight)
        .background(cellBg)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .onTapGesture { onTap() }
    }

    private var cellBg: Color {
        isUsed ? Color.white.opacity(0.06) : Color.cardBg
    }
    private var cellFg: Color {
        if isUsed { return Color.white.opacity(0.15) }
        return isRed ? Color(hex: "c0392b") : Color(hex: "1a1a1a")
    }
}
