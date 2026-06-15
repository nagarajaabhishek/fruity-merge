import SpriteKit

final class MenuScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.98, green: 0.88, blue: 0.60, alpha: 1) // sky blue
        setupBackground()
        setupUI()
    }

    private func setupBackground() {
        // Decorative fruits drifting down
        let fruits: [FruitType] = [.watermelon, .melon, .pineapple, .mango, .orange, .strawberry, .cherry]
        for (i, type) in fruits.enumerated() {
            let node = SKLabelNode(text: type.emoji)
            node.fontSize = CGFloat.random(in: 30...70)
            node.alpha = CGFloat.random(in: 0.15...0.35)
            node.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 60
            )
            node.zPosition = -1
            addChild(node)

            let delay = Double(i) * 0.8 + Double.random(in: 0...1.5)
            let duration = Double.random(in: 8...14)
            let drift = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.moveBy(x: CGFloat.random(in: -40...40), y: -(size.height + 120), duration: duration)
            ])
            let loop = SKAction.repeatForever(SKAction.sequence([
                drift,
                SKAction.run { [weak node] in
                    node?.position = CGPoint(x: CGFloat.random(in: 0...self.size.width), y: self.size.height + 60)
                }
            ]))
            node.run(loop)
        }
    }

    private func setupUI() {
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "Fruity Merge"
        titleLabel.fontSize = 42
        titleLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        addChild(titleLabel)

        let taglineLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        taglineLabel.text = "Drop • Merge • Score"
        taglineLabel.fontSize = 16
        taglineLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.7)
        taglineLabel.horizontalAlignmentMode = .center
        taglineLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62 - 40)
        addChild(taglineLabel)

        // Fruit showcase row
        let showcaseFruits: [FruitType] = [.cherry, .orange, .apple, .pineapple, .watermelon]
        let spacing = size.width / CGFloat(showcaseFruits.count + 1)
        for (i, type) in showcaseFruits.enumerated() {
            let node = SKLabelNode(text: type.emoji)
            node.fontSize = 32
            node.position = CGPoint(x: spacing * CGFloat(i + 1), y: size.height * 0.50)
            addChild(node)
            let bob = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 6, duration: 0.8 + Double(i) * 0.1),
                SKAction.moveBy(x: 0, y: -6, duration: 0.8 + Double(i) * 0.1)
            ])
            node.run(SKAction.repeatForever(bob))
        }

        // Play button
        let playBg = SKShapeNode(rectOf: CGSize(width: 200, height: 58), cornerRadius: 29)
        playBg.fillColor = UIColor(red: 0.30, green: 0.75, blue: 0.40, alpha: 1)
        playBg.strokeColor = .clear
        playBg.position = CGPoint(x: size.width / 2, y: size.height * 0.36)
        playBg.name = "playButton"
        addChild(playBg)

        let playLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        playLabel.text = "Play"
        playLabel.fontSize = 26
        playLabel.fontColor = .white
        playLabel.verticalAlignmentMode = .center
        playLabel.name = "playButton"
        playBg.addChild(playLabel)

        // Best score
        let best = ScoreManager.shared.bestScore
        if best > 0 {
            let bestLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            bestLabel.text = "Best: \(best)"
            bestLabel.fontSize = 17
            bestLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.6)
            bestLabel.horizontalAlignmentMode = .center
            bestLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
            addChild(bestLabel)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if atPoint(location).name == "playButton" {
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view?.presentScene(scene, transition: .doorway(withDuration: 0.5))
        }
    }
}
