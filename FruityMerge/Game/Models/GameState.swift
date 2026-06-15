import Foundation

enum GamePhase {
    case waiting   // waiting for player to drop a fruit
    case dropping  // fruit is falling
    case over      // game over
}

struct GameState {
    var score: Int = 0
    var currentFruit: FruitType = FruitType.randomDroppable()
    var nextFruit: FruitType = FruitType.randomDroppable()
    var phase: GamePhase = .waiting
    var dropX: CGFloat = 0

    mutating func advance() {
        currentFruit = nextFruit
        nextFruit = FruitType.randomDroppable()
        phase = .waiting
    }

    mutating func addPoints(_ pts: Int) {
        score += pts
    }
}
