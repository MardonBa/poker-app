import SwiftUI

struct HoleCardsRowView: View {
    @Bindable var state: GameState

    private let positions = ["UTG","MP","CO","BTN","SB","BB"]

    var body: some View {
        HStack(spacing: 10) {
            // Hole cards
            ForEach(0..<2, id: \.self) { i in
                HoleCardView(card: state.holeCards[i])
                    .onTapGesture { state.pickerTarget = .hole(i) }
            }

            // Position pills
            VStack(spacing: 4) {
                Text("your position")
                    .font(.system(size: 9))
                    .foregroundColor(.appText3)

                FlowLayout(spacing: 3) {
                    ForEach(positions, id: \.self) { pos in
                        PosPill(label: pos, active: state.heroPos == pos) {
                            state.heroPos = pos
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.appBg2)
        .overlay(Divider().background(Color.border), alignment: .top)
    }
}

struct HoleCardView: View {
    let card: PlayingCard?

    var body: some View {
        Group {
            if let c = card {
                VStack(spacing: 1) {
                    Text(c.rank).font(.system(size: 16, weight: .bold))
                    Text(c.suit).font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(c.isRed ? Color(hex: "c0392b") : Color(hex: "1a1a1a"))
                .background(Color.cardBg)
            } else {
                Text("tap")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.2))
                    .background(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1.5, dash: [3])))
            }
        }
        .frame(width: 42, height: 58)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .shadow(color: .black.opacity(0.5), radius: 6, y: 4)
    }
}

struct PosPill: View {
    let label: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .foregroundColor(active ? Color(hex: "c4b8ff") : .appText2)
                .background(active ? Color.accent.opacity(0.15) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(active ? Color.accent.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// Simple flow layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.height }.max() ?? 0 }.reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * spacing
        let width = proposal.width ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.height }.max() ?? 0
            for item in row {
                item.subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private struct RowItem {
        let subview: LayoutSubview
        let size: CGSize
        var width: CGFloat { size.width }
        var height: CGFloat { size.height }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[RowItem]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[RowItem]] = [[]]
        var rowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(RowItem(subview: subview, size: size))
            rowWidth += size.width + spacing
        }
        return rows
    }
}
