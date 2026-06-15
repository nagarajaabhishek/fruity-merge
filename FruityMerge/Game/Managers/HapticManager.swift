import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }

    func drop() {
        lightImpact.impactOccurred()
    }

    func merge(fruitLevel: Int) {
        if fruitLevel >= 10 {
            heavyImpact.impactOccurred(intensity: 1.0)
        } else if fruitLevel >= 5 {
            mediumImpact.impactOccurred()
        } else {
            lightImpact.impactOccurred(intensity: 0.8)
        }
    }

    func gameOver() {
        notification.notificationOccurred(.error)
    }
}
