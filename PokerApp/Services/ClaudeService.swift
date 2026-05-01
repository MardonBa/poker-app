import Foundation

enum ClaudeService {
    static var apiKey: String {
        ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    }

    static func complete(_ prompt: String) async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 512,
            "messages": [["role": "user", "content": prompt]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        return content?.first?["text"] as? String ?? ""
    }

    static func advicePrompt(state: GameState) -> String {
        let board = state.boardCards.compactMap { $0 }.map { $0.rank + $0.suit }.joined(separator: " ")
        let hole  = state.holeCards.compactMap { $0 }.map { $0.rank + $0.suit }.joined(separator: " ")
        let facingStr: String
        switch state.facing {
        case .nothing: facingStr = "nothing"
        case .call:    facingStr = "call of \(state.facingAmt.isEmpty ? "?" : "$\(state.facingAmt)")"
        case .raise:   facingStr = "raise of \(state.facingAmt.isEmpty ? "?" : "$\(state.facingAmt)")"
        }
        let runNote = state.runIt > 1 ? " (running the board \(state.runIt) times)" : ""

        return """
You are a concise poker coach. A player is asking for advice.

Hand situation:
- My hole cards: \(hole.isEmpty ? "unknown" : hole)
- Board: \(board.isEmpty ? "no board" : board)
- Pot: $\(state.pot.isEmpty ? "0" : state.pot)
- My stack: $\(state.myStack.isEmpty ? "0" : state.myStack)
- Facing: \(facingStr)
- Action before me: \(state.actionBefore.isEmpty ? "none noted" : state.actionBefore)
- My position: \(state.heroPos)
- Run it: \(state.runIt)×\(runNote)

Give 2-3 sentences of plain English advice. No jargon without explanation. Be direct about what to do and briefly why. Do NOT use bullet points.
"""
    }

    static func whyPrompt(advice: String) -> String {
        "Expand this poker advice with a brief explanation of the key concept (2-3 sentences, plain English, no jargon without explanation): \"\(advice)\""
    }
}
