# Fruity Merge 🍉

A native iOS fruit drop-and-merge puzzle game built with Swift + SpriteKit. Drop fruits, merge identical ones to create bigger fruits, and see how high you can score — no ads, no data collection, no internet required.

**16 fruits** from tiny cherry to massive watermelon.

---

## Features

- 16 fruit levels: 🍒 → 🫐 → 🍓 → 🍇 → 🥝 → 🍋 → 🍊 → 🍌 → 🥭 → 🍎 → 🍐 → 🍑 → 🥥 → 🍍 → 🍈 → 🍉
- Physics-based gameplay (SpriteKit)
- Satisfying haptics & sound effects
- Personal best score (stored locally on device)
- 100% offline — no network requests, ever
- Zero third-party dependencies

---

## How to Build

Requirements: Xcode 16+, iOS 17+ device or simulator

```bash
# Clone
git clone https://github.com/nagarajaabhishek/fruity-merge.git
cd fruity-merge

# Generate Xcode project (requires xcodegen)
brew install xcodegen
xcodegen generate

# Open in Xcode
open FruityMerge.xcodeproj
```

Then select your target device and hit **Run** (⌘R).

> If you have an Apple Developer account, you can deploy directly to your iPhone — no App Store needed.

---

## How to Play

1. A fruit appears at the top — drag left/right to aim
2. Release to drop it
3. When two identical fruits touch → they merge into the next fruit
4. Keep the pile below the red danger line
5. Game over when any fruit sits above the danger line for 2 seconds

---

## Project Structure

```
FruityMerge/
  App/           — SwiftUI entry + GameViewController
  Game/
    Scenes/      — MenuScene, GameScene, GameOverScene
    Nodes/       — FruitNode, WallNode, DropIndicatorNode
    Models/      — FruitType, GameState
    Managers/    — HapticManager, SoundManager, ScoreManager
  Resources/     — Sounds, Assets
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs welcome — especially:
- New fruit themes (emoji swap, new progression)
- Sound effects
- Accessibility improvements

---

## License

MIT — see [LICENSE](LICENSE).

No ads. No tracking. No data collected. Just fruits.
