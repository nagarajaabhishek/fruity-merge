# Fruity Merge — Cursor Handoff

Native iOS fruit-drop-and-merge game. Swift + SpriteKit. No ads, no data, MIT open source.

**GitHub:** https://github.com/nagarajaabhishek/fruity-merge
**Obsidian:** `projects/fruity-merge/` (full context + session logs)

---

## Where we left off

All Swift source files are written. The Xcode project has NOT been generated yet.

**First thing to do:**
```bash
cd /Users/abhisheknagaraja/Documents/Juice_Merge
xcodegen generate          # generates FruityMerge.xcodeproj from project.yml
open FruityMerge.xcodeproj
```

Then build on iPhone simulator (iOS 17+). Fix any compile errors, then:
```bash
git add .
git commit -m "feat: initial SpriteKit game scaffold"
git push -u origin main
```

---

## Project structure

```
FruityMerge/
  App/
    FruityMergeApp.swift       ← SwiftUI entry, wraps GameViewController
    GameViewController.swift   ← UIViewController hosting SKView
  Game/
    Scenes/
      MenuScene.swift          ← title screen, play button, animated bg
      GameScene.swift          ← main game loop (drop, physics, merge, score, pause)
      GameOverScene.swift      ← final score, play again, share
    Nodes/
      FruitNode.swift          ← SKShapeNode circle + emoji label + physics
      WallNode.swift           ← static wall/floor boundaries
      DropIndicatorNode.swift  ← dashed vertical aim line
    Models/
      FruitType.swift          ← 16-level enum (cherry→watermelon) with radius/points/emoji/color
      GameState.swift          ← score, currentFruit, nextFruit, phase
    Managers/
      ScoreManager.swift       ← UserDefaults bestScore + gamesPlayed
      HapticManager.swift      ← UIImpactFeedbackGenerator wrappers
      SoundManager.swift       ← AVAudioPlayer, pitch-shifted merge sounds
project.yml                    ← xcodegen config (source of truth, not .xcodeproj)
```

---

## Milestones

- [x] M1 — Repo + code scaffold ← **HERE**
- [ ] M2 — Build + fix compile errors, first working simulator run
- [ ] M3 — Assets: AppIcon, spark texture for particles, placeholder sounds
- [ ] M4 — Polish: tune physics feel, particle burst, UI animations
- [ ] M5 — Open source: GitHub Actions CI, CONTRIBUTING.md
- [ ] M6 — App Store: icon all sizes, screenshots, TestFlight, submit

---

## Key implementation notes

- **Merge deferral:** merges run after `SKAction.wait(0.01)` to avoid SpriteKit physics body conflicts when removing nodes mid-contact
- **Droppable fruits:** only first 6 types (cherry→lemon) can be dropped — prevents immediate game over with huge fruits
- **Danger line:** fruit must sit above `dangerLineY` for **2 full seconds** before game over (not instant)
- **Particles:** programmatic `SKEmitterNode`, no `.sks` file needed. Needs `spark` texture in Assets — use any small white dot PNG, or replace with `SKTexture(imageNamed: "")` and it'll use a default square
- **Sound:** `SoundManager` expects `drop.wav`, `merge.wav`, `gameover.wav` in bundle. If missing, it fails silently (guard let). Add real sounds or use `SKAction.playSoundFileNamed` with a system sound as placeholder
- **Physics:** gravity `(0, -5)`, restitution `0.2`, friction `0.4` — tune these for game feel

---

## Fruit set (16 levels)

| # | Fruit | Emoji | Radius | Points |
|---|---|---|---|---|
| 0 | Cherry | 🍒 | 16 | 1 |
| 1 | Blueberry | 🫐 | 22 | 3 |
| 2 | Strawberry | 🍓 | 28 | 6 |
| 3 | Grape | 🍇 | 34 | 10 |
| 4 | Kiwi | 🥝 | 40 | 15 |
| 5 | Lemon | 🍋 | 46 | 21 |
| 6 | Orange | 🍊 | 52 | 28 |
| 7 | Banana | 🍌 | 57 | 36 |
| 8 | Mango | 🥭 | 62 | 45 |
| 9 | Apple | 🍎 | 68 | 55 |
| 10 | Pear | 🍐 | 74 | 66 |
| 11 | Peach | 🍑 | 80 | 78 |
| 12 | Coconut | 🥥 | 86 | 91 |
| 13 | Pineapple | 🍍 | 94 | 105 |
| 14 | Melon | 🍈 | 104 | 120 |
| 15 | Watermelon | 🍉 | 116 | 136 |
