import SpriteKit
import UIKit

final class GameOverScene: SKScene {
    private let finalScore: Int
    private let isNewBest: Bool

    init(size: CGSize, score: Int, isNewBest: Bool) {
        self.finalScore = score
        self.isNewBest = isNewBest
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.98, green: 0.88, blue: 0.60, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        // Game Over title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "Game Over"
        titleLabel.fontSize = 40
        titleLabel.fontColor = UIColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        titleLabel.setScale(0)
        addChild(titleLabel)
        titleLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))

        // Score display
        let scoreValueLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreValueLabel.text = "\(finalScore)"
        scoreValueLabel.fontSize = 64
        scoreValueLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 1)
        scoreValueLabel.horizontalAlignmentMode = .center
        scoreValueLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.54)
        addChild(scoreValueLabel)

        let scoreTitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreTitleLabel.text = "SCORE"
        scoreTitleLabel.fontSize = 13
        scoreTitleLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.6)
        scoreTitleLabel.horizontalAlignmentMode = .center
        scoreTitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.54 - 46)
        addChild(scoreTitleLabel)

        // New best badge
        if isNewBest {
            let crownLabel = SKLabelNode(text: "👑 New Best!")
            crownLabel.fontSize = 22
            crownLabel.horizontalAlignmentMode = .center
            crownLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.54 - 80)
            crownLabel.alpha = 0
            addChild(crownLabel)
            crownLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.4),
                SKAction.fadeIn(withDuration: 0.3)
            ]))
        } else {
            let bestLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            bestLabel.text = "Best: \(ScoreManager.shared.bestScore)"
            bestLabel.fontSize = 17
            bestLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.6)
            bestLabel.horizontalAlignmentMode = .center
            bestLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.54 - 80)
            addChild(bestLabel)
        }

        // Play Again button
        let playBg = SKShapeNode(rectOf: CGSize(width: 220, height: 56), cornerRadius: 28)
        playBg.fillColor = UIColor(red: 0.30, green: 0.75, blue: 0.40, alpha: 1)
        playBg.strokeColor = .clear
        playBg.position = CGPoint(x: size.width / 2, y: size.height * 0.34)
        playBg.name = "playAgainBtn"
        addChild(playBg)

        let playLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        playLabel.text = "Play Again"
        playLabel.fontSize = 22
        playLabel.fontColor = .white
        playLabel.verticalAlignmentMode = .center
        playLabel.name = "playAgainBtn"
        playBg.addChild(playLabel)

        // Menu button
        let menuBg = SKShapeNode(rectOf: CGSize(width: 220, height: 56), cornerRadius: 28)
        menuBg.fillColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.12)
        menuBg.strokeColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.3)
        menuBg.lineWidth = 1.5
        menuBg.position = CGPoint(x: size.width / 2, y: size.height * 0.34 - 72)
        menuBg.name = "menuBtn"
        addChild(menuBg)

        let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuLabel.text = "Menu"
        menuLabel.fontSize = 22
        menuLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 1)
        menuLabel.verticalAlignmentMode = .center
        menuLabel.name = "menuBtn"
        menuBg.addChild(menuLabel)

        // Share button
        let shareLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        shareLabel.text = "Share Score ↗"
        shareLabel.fontSize = 15
        shareLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.5)
        shareLabel.horizontalAlignmentMode = .center
        shareLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.34 - 130)
        shareLabel.name = "shareBtn"
        addChild(shareLabel)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let name = atPoint(touch.location(in: self)).name

        switch name {
        case "playAgainBtn":
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view?.presentScene(scene, transition: .doorway(withDuration: 0.5))

        case "menuBtn":
            let scene = MenuScene(size: size)
            scene.scaleMode = scaleMode
            view?.presentScene(scene, transition: .fade(withDuration: 0.4))

        case "shareBtn":
            shareScore()

        default:
            break
        }
    }

    private func shareScore() {
        let text = "I scored \(finalScore) in Fruity Merge! 🍉 Can you beat me?"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        view?.window?.rootViewController?.present(vc, animated: true)
    }
}
