import SpriteKit

final class FruitNode: SKNode {
    let fruitType: FruitType
    private let circle: SKShapeNode
    private let label: SKLabelNode
    var isDropped = false
    var isMergeImmune = false  // true briefly after spawning from a merge
    var dangerTimer: TimeInterval = 0

    static let category: UInt32 = 0x1 << 0
    static let wallCategory: UInt32 = 0x1 << 1

    init(type: FruitType) {
        self.fruitType = type
        let r = type.radius

        circle = SKShapeNode(circleOfRadius: r)
        circle.fillColor = .clear
        circle.strokeColor = .clear
        circle.lineWidth = 0

        label = SKLabelNode(text: type.emoji)
        label.fontSize = r * 2.0
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        super.init()

        addChild(circle)
        addChild(label)
        name = "fruit_\(type.rawValue)"
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    func enablePhysics() {
        let body = SKPhysicsBody(circleOfRadius: fruitType.radius)
        body.isDynamic = true
        body.restitution = 0.2
        body.friction = 0.4
        body.linearDamping = 0.1
        body.angularDamping = 0.5
        body.density = 1.0 + CGFloat(fruitType.rawValue) * 0.15
        body.categoryBitMask = FruitNode.category
        body.contactTestBitMask = FruitNode.category
        body.collisionBitMask = FruitNode.category | FruitNode.wallCategory
        physicsBody = body
        isDropped = true
    }

    func popEffect(completion: @escaping () -> Void) {
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.08),
            SKAction.scale(to: 0.0, duration: 0.12)
        ])
        run(scale) { completion() }
    }

    func spawnEffect() {
        setScale(0)
        run(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.08)
        ]))
    }
}
