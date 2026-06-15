import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Layout constants
    private let wallThickness: CGFloat = 6
    private let baseHeaderHeight: CGFloat = 120  // UI area below safe zone
    private var safeTop: CGFloat = 0             // Dynamic Island / notch inset
    private var headerHeight: CGFloat = 120      // set in didMove once safeTop is known
    private let floorY: CGFloat = 30             // visual floor line
    private var ceilingY: CGFloat = 0            // invisible game-over threshold at top
    private var dropMinX: CGFloat = 0
    private var dropMaxX: CGFloat = 0

    // MARK: - State
    private var state = GameState()
    private var pendingMerges = Set<ObjectIdentifier>()
    private var activeFruits: [FruitNode] = []
    private var currentFruitNode: FruitNode?
    private var isGameOver = false
    private var contactScanTimer: TimeInterval = 0

    // MARK: - UI nodes
    private var scoreLabel: SKLabelNode!
    private var nextFruitLabel: SKLabelNode!
    private var nextFruitEmoji: SKLabelNode!
    private var dropIndicator: DropIndicatorNode!
    private var dangerLine: SKShapeNode!
    private var pauseButton: SKLabelNode!

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.98, green: 0.88, blue: 0.60, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        physicsWorld.contactDelegate = self
        HapticManager.shared.prepare()
        SoundManager.shared.playAmbient()
        // Read safe area before any layout so header clears Dynamic Island / notch
        safeTop = view.safeAreaInsets.top
        headerHeight = baseHeaderHeight + safeTop
        setupBoundaries()
        setupUI()
        spawnCurrentFruit()
    }

    override func willMove(from view: SKView) {
        SoundManager.shared.stopAmbient()
    }

    // MARK: - Setup
    private func setupBoundaries() {
        let playAreaTop = size.height - headerHeight
        let playAreaLeft: CGFloat = wallThickness
        let playAreaRight = size.width - wallThickness

        // Game over triggers when a settled fruit reaches this height (just below header)
        ceilingY = playAreaTop - 10
        dropMinX = playAreaLeft + 20
        dropMaxX = playAreaRight - 20
        state.dropX = size.width / 2

        // Physics container: full play area from floor to just below header
        let rect = CGRect(
            x: playAreaLeft,
            y: floorY,
            width: playAreaRight - playAreaLeft,
            height: playAreaTop - floorY
        )
        let walls = WallNode(rect: rect)
        addChild(walls)

        // Visible left wall — sandy/warm tone
        let leftWall = SKShapeNode(rectOf: CGSize(width: wallThickness, height: playAreaTop - floorY))
        leftWall.fillColor = UIColor(red: 0.91, green: 0.76, blue: 0.53, alpha: 0.6)
        leftWall.strokeColor = UIColor(red: 0.80, green: 0.60, blue: 0.35, alpha: 0.8)
        leftWall.position = CGPoint(x: wallThickness / 2, y: (playAreaTop + floorY) / 2)
        addChild(leftWall)

        // Visible right wall
        let rightWall = SKShapeNode(rectOf: CGSize(width: wallThickness, height: playAreaTop - floorY))
        rightWall.fillColor = UIColor(red: 0.91, green: 0.76, blue: 0.53, alpha: 0.6)
        rightWall.strokeColor = UIColor(red: 0.80, green: 0.60, blue: 0.35, alpha: 0.8)
        rightWall.position = CGPoint(x: size.width - wallThickness / 2, y: (playAreaTop + floorY) / 2)
        addChild(rightWall)

        // Sandy floor line at the bottom
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: playAreaLeft, y: floorY))
        linePath.addLine(to: CGPoint(x: playAreaRight, y: floorY))
        dangerLine = SKShapeNode(path: linePath)
        dangerLine.strokeColor = UIColor(red: 0.80, green: 0.60, blue: 0.35, alpha: 0.9)
        dangerLine.lineWidth = 3
        dangerLine.lineCap = .round
        let dashes: [CGFloat] = [10, 6]
        dangerLine.path = linePath.copy(dashingWithPhase: 0, lengths: dashes)
        addChild(dangerLine)

        // Drop indicator — short line below the current fruit
        // fruitY centers the held fruit in the content area of the header (below safe zone)
        let fruitY = size.height - safeTop - baseHeaderHeight / 2
        let indicatorHeight = baseHeaderHeight * 0.35
        dropIndicator = DropIndicatorNode(height: indicatorHeight)
        dropIndicator.position = CGPoint(x: state.dropX, y: fruitY)
        addChild(dropIndicator)
    }

    private func setupUI() {
        // All top-row elements sit safeTop + 20pt below the physical top edge
        let topRowY = size.height - safeTop - 28
        let topLabelY = size.height - safeTop - 46

        // Score
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 1)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: size.width - 24, y: topRowY)
        scoreLabel.text = "0"
        addChild(scoreLabel)

        // "SCORE" label
        let scoreTitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreTitleLabel.fontSize = 11
        scoreTitleLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.6)
        scoreTitleLabel.horizontalAlignmentMode = .right
        scoreTitleLabel.verticalAlignmentMode = .center
        scoreTitleLabel.position = CGPoint(x: size.width - 24, y: topLabelY)
        scoreTitleLabel.text = "SCORE"
        addChild(scoreTitleLabel)

        // Next fruit preview
        let nextLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        nextLabel.fontSize = 11
        nextLabel.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.6)
        nextLabel.horizontalAlignmentMode = .left
        nextLabel.verticalAlignmentMode = .center
        nextLabel.position = CGPoint(x: 24, y: topLabelY)
        nextLabel.text = "NEXT"
        addChild(nextLabel)

        nextFruitEmoji = SKLabelNode(text: state.nextFruit.emoji)
        nextFruitEmoji.fontSize = 36
        nextFruitEmoji.horizontalAlignmentMode = .left
        nextFruitEmoji.verticalAlignmentMode = .center
        nextFruitEmoji.position = CGPoint(x: 20, y: topRowY)
        addChild(nextFruitEmoji)

        // Pause button
        pauseButton = SKLabelNode(text: "⏸")
        pauseButton.fontSize = 22
        pauseButton.horizontalAlignmentMode = .center
        pauseButton.verticalAlignmentMode = .center
        pauseButton.position = CGPoint(x: size.width / 2, y: topRowY)
        pauseButton.name = "pauseButton"
        addChild(pauseButton)

        // Evolution chain strip — second row in header
        setupEvolutionStrip()
    }

    private func setupEvolutionStrip() {
        let allFruits = FruitType.allCases
        let stripY = size.height - headerHeight + 22
        let totalFruits = allFruits.count  // 16
        let spacing = (size.width - 16) / CGFloat(totalFruits)

        for (i, type) in allFruits.enumerated() {
            let x = 8 + spacing * CGFloat(i) + spacing / 2

            let emojiLabel = SKLabelNode(text: type.emoji)
            emojiLabel.fontSize = 13
            emojiLabel.horizontalAlignmentMode = .center
            emojiLabel.verticalAlignmentMode = .center
            emojiLabel.position = CGPoint(x: x, y: stripY)
            emojiLabel.alpha = 0.45
            emojiLabel.name = "strip_\(i)"
            addChild(emojiLabel)

            // Arrow between fruits (except after last)
            if i < totalFruits - 1 {
                let arrow = SKLabelNode(text: "›")
                arrow.fontName = "AvenirNext-Medium"
                arrow.fontSize = 8
                arrow.fontColor = UIColor(red: 0.10, green: 0.25, blue: 0.45, alpha: 0.25)
                arrow.horizontalAlignmentMode = .center
                arrow.verticalAlignmentMode = .center
                arrow.position = CGPoint(x: x + spacing / 2, y: stripY)
                addChild(arrow)
            }
        }
    }

    private func highlightEvolutionStrip(for type: FruitType) {
        for i in 0..<FruitType.allCases.count {
            guard let node = childNode(withName: "strip_\(i)") as? SKLabelNode else { continue }
            if i == type.rawValue {
                node.alpha = 1.0
                node.fontSize = 17
            } else if i == type.rawValue + 1 {
                node.alpha = 0.7  // next fruit slightly highlighted
                node.fontSize = 13
            } else {
                node.alpha = 0.3
                node.fontSize = 13
            }
        }
    }

    private func updateScoreLabel() {
        scoreLabel.text = "\(state.score)"
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ])
        scoreLabel.run(bounce)
    }

    // MARK: - Fruit Spawning
    private func spawnCurrentFruit() {
        guard !isGameOver else { return }
        let fruit = FruitNode(type: state.currentFruit)
        let fruitY = size.height - safeTop - baseHeaderHeight / 2
        fruit.position = CGPoint(x: state.dropX, y: fruitY)
        fruit.spawnEffect()
        addChild(fruit)
        currentFruitNode = fruit
        state.phase = .waiting
        highlightEvolutionStrip(for: state.currentFruit)

        dropIndicator.isHidden = false
        dropIndicator.moveTo(x: state.dropX)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let node = atPoint(location) as? SKLabelNode, node.name == "pauseButton" {
            showPause()
            return
        }

        guard state.phase == .waiting else { return }
        updateDropX(from: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, state.phase == .waiting else { return }
        updateDropX(from: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if childNode(withName: "pauseOverlay") != nil {
            handlePauseOverlayTap(location: location)
            return
        }
        guard state.phase == .waiting else { return }
        dropCurrentFruit()
    }

    private func updateDropX(from location: CGPoint) {
        let clampedX = min(max(location.x, dropMinX), dropMaxX)
        state.dropX = clampedX
        currentFruitNode?.position.x = clampedX
        dropIndicator.moveTo(x: clampedX)
    }

    private func dropCurrentFruit() {
        guard let fruit = currentFruitNode, state.phase == .waiting else { return }
        state.phase = .dropping
        dropIndicator.isHidden = true
        fruit.enablePhysics()
        activeFruits.append(fruit)
        currentFruitNode = nil
        HapticManager.shared.drop()
        SoundManager.shared.playDrop()

        // Advance state and queue next fruit spawn
        state.advance()
        nextFruitEmoji.text = state.nextFruit.emoji

        run(SKAction.wait(forDuration: 0.5)) { [weak self] in
            self?.spawnCurrentFruit()
        }
    }

    // MARK: - Collision / Merge
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as? FruitNode
        let nodeB = contact.bodyB.node as? FruitNode

        guard let a = nodeA, let b = nodeB,
              a.fruitType == b.fruitType,
              a.isDropped, b.isDropped,
              !a.isMergeImmune, !b.isMergeImmune,
              !pendingMerges.contains(ObjectIdentifier(a)),
              !pendingMerges.contains(ObjectIdentifier(b)) else { return }

        pendingMerges.insert(ObjectIdentifier(a))
        pendingMerges.insert(ObjectIdentifier(b))

        let midpoint = CGPoint(
            x: (a.position.x + b.position.x) / 2,
            y: (a.position.y + b.position.y) / 2
        )
        let mergedType = a.fruitType

        run(SKAction.wait(forDuration: 0.01)) { [weak self] in
            self?.performMerge(nodeA: a, nodeB: b, at: midpoint, type: mergedType)
        }
    }

    private func performMerge(nodeA: FruitNode, nodeB: FruitNode, at point: CGPoint, type: FruitType) {
        guard nodeA.parent != nil, nodeB.parent != nil else {
            pendingMerges.remove(ObjectIdentifier(nodeA))
            pendingMerges.remove(ObjectIdentifier(nodeB))
            return
        }

        activeFruits.removeAll { $0 === nodeA || $0 === nodeB }

        // Null physics bodies immediately so no new contacts can fire during the pop animation
        nodeA.physicsBody = nil
        nodeB.physicsBody = nil
        nodeA.popEffect { nodeA.removeFromParent() }
        nodeB.popEffect { nodeB.removeFromParent() }

        pendingMerges.remove(ObjectIdentifier(nodeA))
        pendingMerges.remove(ObjectIdentifier(nodeB))

        spawnMergeParticles(at: point, color: type.color)
        HapticManager.shared.merge(fruitLevel: type.rawValue)
        SoundManager.shared.playMerge(fruitLevel: type.rawValue)
        state.addPoints(type.next?.points ?? type.points * 2)
        updateScoreLabel()

        guard let nextType = type.next else { return }
        run(SKAction.wait(forDuration: 0.1)) { [weak self] in
            guard let self else { return }
            let merged = FruitNode(type: nextType)
            merged.position = point
            merged.isMergeImmune = true   // prevent instant chain-merge
            merged.enablePhysics()
            merged.spawnEffect()
            self.addChild(merged)
            self.activeFruits.append(merged)
            // Lift immunity after the fruit has had time to settle away from neighbours
            merged.run(SKAction.wait(forDuration: 0.4)) { merged.isMergeImmune = false }
        }
    }

    // MARK: - Particles
    private func spawnMergeParticles(at point: CGPoint, color: UIColor) {
        let burst = SKEmitterNode()
        burst.particleTexture = SKTexture(imageNamed: "spark")
        burst.particleColor = color
        burst.particleColorBlendFactor = 1.0
        burst.particleBirthRate = 200
        burst.numParticlesToEmit = 20
        burst.particleLifetime = 0.4
        burst.particleLifetimeRange = 0.2
        burst.particleSpeed = 100
        burst.particleSpeedRange = 60
        burst.emissionAngleRange = .pi * 2
        burst.particleScale = 0.08
        burst.particleScaleRange = 0.04
        burst.particleAlpha = 1.0
        burst.particleAlphaSpeed = -2.5
        burst.position = point
        addChild(burst)
        burst.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Game Over Detection + Stuck-merge catch-up
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        for fruit in activeFruits where fruit.isDropped {
            if fruit.position.y > ceilingY {
                let vy = abs(fruit.physicsBody?.velocity.dy ?? 999)
                let vx = abs(fruit.physicsBody?.velocity.dx ?? 999)
                if vy < 30 && vx < 30 {
                    fruit.dangerTimer += 1.0 / 60.0
                    if fruit.dangerTimer > 1.5 {
                        triggerGameOver()
                        return
                    }
                } else {
                    fruit.dangerTimer = 0
                }
            } else {
                fruit.dangerTimer = 0
            }
        }

        // SpriteKit's didBegin only fires when contact starts — if isMergeImmune blocks
        // a merge and then lifts, the fruits are already touching so didBegin won't re-fire.
        // Scan every 0.3s and trigger any missed merges by distance check.
        contactScanTimer += 1.0 / 60.0
        if contactScanTimer >= 0.3 {
            contactScanTimer = 0
            scanForMissedContacts()
        }
    }

    private func scanForMissedContacts() {
        let candidates = activeFruits.filter { $0.isDropped && !$0.isMergeImmune }
        for i in 0..<candidates.count {
            let a = candidates[i]
            guard !pendingMerges.contains(ObjectIdentifier(a)) else { continue }
            for j in (i + 1)..<candidates.count {
                let b = candidates[j]
                guard b.fruitType == a.fruitType,
                      !pendingMerges.contains(ObjectIdentifier(b)) else { continue }
                let dx = a.position.x - b.position.x
                let dy = a.position.y - b.position.y
                let dist = (dx * dx + dy * dy).squareRoot()
                let touchDist = a.fruitType.radius + b.fruitType.radius
                if dist <= touchDist * 1.2 {
                    let mid = CGPoint(x: (a.position.x + b.position.x) / 2,
                                     y: (a.position.y + b.position.y) / 2)
                    pendingMerges.insert(ObjectIdentifier(a))
                    pendingMerges.insert(ObjectIdentifier(b))
                    run(SKAction.wait(forDuration: 0.01)) { [weak self] in
                        self?.performMerge(nodeA: a, nodeB: b, at: mid, type: a.fruitType)
                    }
                    return  // one merge at a time per scan
                }
            }
        }
    }

    private func triggerGameOver() {
        isGameOver = true
        state.phase = .over
        currentFruitNode?.removeFromParent()
        dropIndicator.isHidden = true
        HapticManager.shared.gameOver()
        SoundManager.shared.playGameOver()
        SoundManager.shared.stopAmbient()

        let isNewBest = ScoreManager.shared.submit(score: state.score)

        run(SKAction.wait(forDuration: 0.8)) { [weak self] in
            guard let self else { return }
            let scene = GameOverScene(size: self.size, score: self.state.score, isNewBest: isNewBest)
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene, transition: .fade(withDuration: 0.5))
        }
    }

    // MARK: - Pause
    private func showPause() {
        isPaused = true
        SoundManager.shared.stopAmbient()

        let overlay = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlay.fillColor = UIColor.black.withAlphaComponent(0.6)
        overlay.strokeColor = .clear
        overlay.zPosition = 100
        overlay.name = "pauseOverlay"
        addChild(overlay)

        let resumeBtn = makeButton(text: "▶  Resume", name: "resumeBtn", y: size.height / 2 + 30)
        let menuBtn = makeButton(text: "⌂  Menu", name: "menuBtn", y: size.height / 2 - 30)
        overlay.addChild(resumeBtn)
        overlay.addChild(menuBtn)
    }

    private func makeButton(text: String, name: String, y: CGFloat) -> SKLabelNode {
        let btn = SKLabelNode(fontNamed: "AvenirNext-Bold")
        btn.text = text
        btn.fontSize = 22
        btn.fontColor = .white
        btn.horizontalAlignmentMode = .center
        btn.verticalAlignmentMode = .center
        btn.position = CGPoint(x: size.width / 2, y: y)
        btn.name = name
        return btn
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}

    private func handlePauseOverlayTap(location: CGPoint) {
        guard let overlay = childNode(withName: "pauseOverlay") else { return }
        let loc = convert(location, to: overlay)
        guard let node = overlay.nodes(at: loc).compactMap({ $0 as? SKLabelNode }).first else { return }
        handlePauseButton(name: node.name)
    }

    private func handlePauseButton(name: String?) {
        switch name {
        case "resumeBtn":
            childNode(withName: "pauseOverlay")?.removeFromParent()
            isPaused = false
            SoundManager.shared.playAmbient()
        case "menuBtn":
            childNode(withName: "pauseOverlay")?.removeFromParent()
            isPaused = false
            let menu = MenuScene(size: size)
            menu.scaleMode = scaleMode
            view?.presentScene(menu, transition: .fade(withDuration: 0.4))
        default:
            break
        }
    }
}
