import SpriteKit

final class DropIndicatorNode: SKNode {
    private let line: SKShapeNode

    init(height: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -height))

        line = SKShapeNode(path: path)
        line.strokeColor = UIColor.white.withAlphaComponent(0.3)
        line.lineWidth = 1.5
        line.lineCap = .round

        // Dashed line pattern
        let pattern: [CGFloat] = [8, 6]
        line.path = path.copy(dashingWithPhase: 0, lengths: pattern)

        super.init()
        addChild(line)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    func moveTo(x: CGFloat) {
        position.x = x
    }
}
