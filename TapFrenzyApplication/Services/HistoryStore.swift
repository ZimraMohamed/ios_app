import Foundation


final class HistoryStore {
    static let shared = HistoryStore()
    private init() {}

    
    private let maxEntriesPerGame = 100

    private func storageKey(for game: GameID) -> String {
        "playHistory_\(game.rawValue)"
    }

    
    func records(for game: GameID) -> [PlayRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey(for: game)),
              let decoded = try? JSONDecoder().decode([PlayRecord].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.date > $1.date }
    }


    @discardableResult
    func addRecord(score: Int, detail: String? = nil, for game: GameID) -> PlayRecord {
        var current = records(for: game)
        let newHigh = score > (current.map(\.score).max() ?? -1)
        let record = PlayRecord(date: Date(), score: score, detail: detail, isHighScore: newHigh)
        current.insert(record, at: 0)
        if current.count > maxEntriesPerGame {
            current = Array(current.prefix(maxEntriesPerGame))
        }
        save(current, for: game)
        return record
    }

    func clearHistory(for game: GameID) {
        UserDefaults.standard.removeObject(forKey: storageKey(for: game))
    }

    func bestScore(for game: GameID) -> Int {
        records(for: game).map(\.score).max() ?? 0
    }

    func averageScore(for game: GameID) -> Int {
        let all = records(for: game)
        guard !all.isEmpty else { return 0 }
        return all.map(\.score).reduce(0, +) / all.count
    }

    private func save(_ records: [PlayRecord], for game: GameID) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: storageKey(for: game))
    }
}
