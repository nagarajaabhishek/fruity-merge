import UIKit

enum FruitType: Int, CaseIterable {
    case cherry = 0
    case blueberry = 1
    case strawberry = 2
    case grape = 3
    case kiwi = 4
    case lemon = 5
    case orange = 6
    case banana = 7
    case mango = 8
    case apple = 9
    case pear = 10
    case peach = 11
    case coconut = 12
    case pineapple = 13
    case melon = 14
    case watermelon = 15

    var radius: CGFloat {
        let radii: [CGFloat] = [12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 53, 58, 63, 68, 75, 84]
        return radii[rawValue]
    }

    var points: Int {
        let pts = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136]
        return pts[rawValue]
    }

    var emoji: String {
        let emojis = ["🍒", "🫐", "🍓", "🍇", "🥝", "🍋", "🍊", "🍌", "🥭", "🍎", "🍐", "🍑", "🥥", "🍍", "🍈", "🍉"]
        return emojis[rawValue]
    }

    var color: UIColor {
        let colors: [UIColor] = [
            UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1), // cherry — deep red
            UIColor(red: 0.25, green: 0.10, blue: 0.55, alpha: 1), // blueberry — indigo
            UIColor(red: 0.95, green: 0.25, blue: 0.35, alpha: 1), // strawberry — bright red-pink
            UIColor(red: 0.45, green: 0.15, blue: 0.55, alpha: 1), // grape — purple
            UIColor(red: 0.35, green: 0.65, blue: 0.20, alpha: 1), // kiwi — green
            UIColor(red: 0.98, green: 0.90, blue: 0.10, alpha: 1), // lemon — yellow
            UIColor(red: 0.98, green: 0.55, blue: 0.10, alpha: 1), // orange — orange
            UIColor(red: 0.95, green: 0.85, blue: 0.15, alpha: 1), // banana — golden yellow
            UIColor(red: 0.95, green: 0.45, blue: 0.10, alpha: 1), // mango — deep orange
            UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1), // apple — red
            UIColor(red: 0.65, green: 0.80, blue: 0.30, alpha: 1), // pear — yellow-green
            UIColor(red: 0.98, green: 0.60, blue: 0.45, alpha: 1), // peach — peach
            UIColor(red: 0.75, green: 0.65, blue: 0.50, alpha: 1), // coconut — tan
            UIColor(red: 0.98, green: 0.75, blue: 0.15, alpha: 1), // pineapple — bright yellow
            UIColor(red: 0.40, green: 0.75, blue: 0.35, alpha: 1), // melon — medium green
            UIColor(red: 0.20, green: 0.65, blue: 0.25, alpha: 1), // watermelon — dark green
        ]
        return colors[rawValue]
    }

    var next: FruitType? {
        FruitType(rawValue: rawValue + 1)
    }

    // First 5 fruits are droppable — matches original Suika Game (5 smallest, equal probability)
    static var droppable: [FruitType] {
        Array(FruitType.allCases.prefix(5))
    }

    // Flat 20% each — exactly how the original Suika Game works
    static func randomDroppable() -> FruitType {
        droppable.randomElement()!
    }
}
