import SpriteKit

final class WallNode: SKNode {
    init(rect: CGRect) {
        super.init()
        // Open-top U-shape: left wall + floor + right wall. No ceiling so fruits fall in freely.
        let path = CGMutablePath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        let body = SKPhysicsBody(edgeChainFrom: path)
        body.isDynamic = false
        body.restitution = 0.1
        body.friction = 0.6
        body.categoryBitMask = FruitNode.wallCategory
        body.collisionBitMask = FruitNode.category
        body.contactTestBitMask = 0
        physicsBody = body
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
