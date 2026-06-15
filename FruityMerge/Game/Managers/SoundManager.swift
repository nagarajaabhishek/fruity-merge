import AVFoundation

final class SoundManager {
    static let shared = SoundManager()
    private init() {}

    private var dropPlayer: AVAudioPlayer?
    private var gameOverPlayer: AVAudioPlayer?
    private var mergePlayers: [AVAudioPlayer] = []
    private var ambientPlayer: AVAudioPlayer?

    var isSoundEnabled: Bool = true

    func setup() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        loadSounds()
    }

    private func loadSounds() {
        dropPlayer = player(for: "drop")
        gameOverPlayer = player(for: "gameover")
        // Pre-load a pool of merge players for rapid merges
        mergePlayers = (0..<4).compactMap { _ in player(for: "merge") }
    }

    private func player(for name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return nil }
        return try? AVAudioPlayer(contentsOf: url)
    }

    func playDrop() {
        guard isSoundEnabled else { return }
        dropPlayer?.play()
    }

    func playMerge(fruitLevel: Int) {
        guard isSoundEnabled else { return }
        let player = mergePlayers.first(where: { !$0.isPlaying }) ?? mergePlayers.first
        let pitchScale = 1.0 + (Double(fruitLevel) * 0.08)
        player?.rate = Float(min(pitchScale, 2.0))
        player?.play()
    }

    func playGameOver() {
        guard isSoundEnabled else { return }
        gameOverPlayer?.play()
    }

    func playAmbient() {
        guard isSoundEnabled else { return }
        guard let url = Bundle.main.url(forResource: "ambient", withExtension: "mp3") else { return }
        ambientPlayer = try? AVAudioPlayer(contentsOf: url)
        ambientPlayer?.numberOfLoops = -1
        ambientPlayer?.volume = 0.3
        ambientPlayer?.play()
    }

    func stopAmbient() {
        ambientPlayer?.stop()
    }
}
