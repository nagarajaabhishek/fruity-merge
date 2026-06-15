import Foundation

final class ScoreManager {
    static let shared = ScoreManager()
    private init() {}

    private let bestScoreKey = "bestScore"
    private let gamesPlayedKey = "gamesPlayed"

    var bestScore: Int {
        get { UserDefaults.standard.integer(forKey: bestScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: bestScoreKey) }
    }

    var gamesPlayed: Int {
        get { UserDefaults.standard.integer(forKey: gamesPlayedKey) }
        set { UserDefaults.standard.set(newValue, forKey: gamesPlayedKey) }
    }

    @discardableResult
    func submit(score: Int) -> Bool {
        gamesPlayed += 1
        if score > bestScore {
            bestScore = score
            return true
        }
        return false
    }
}
