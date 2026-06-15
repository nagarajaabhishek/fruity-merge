# Contributing to Fruity Merge

Thanks for your interest in contributing! This project is open source and welcomes improvements.

## Who can do what

| Action | Who |
|--------|-----|
| **Clone / pull / fork** | Anyone — the repo is public |
| **Open a pull request** | Anyone with a GitHub account |
| **Push directly to `main`** | Maintainers only (via reviewed PRs) |
| **Become a maintainer** | Ask by opening an issue — see below |

## How to contribute (recommended)

1. **Fork** the repo on GitHub: https://github.com/nagarajaabhishek/fruity-merge/fork
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/fruity-merge.git
   cd fruity-merge
   ```
3. **Create a branch** for your change:
   ```bash
   git checkout -b feat/my-improvement
   ```
4. **Make your changes**, build in Xcode, and test on the iOS simulator.
5. **Commit** with a clear message (e.g. `feat: add cherry splash sound`).
6. **Push** to your fork and **open a Pull Request** against `main`.

We review PRs as soon as we can. Small, focused changes are easiest to merge.

## Requesting maintainer access

If you plan to contribute regularly and want direct push access to this repository (not just your fork), open a [GitHub Issue](https://github.com/nagarajaabhishek/fruity-merge/issues/new) titled **"Maintainer access request"** and briefly describe:

- What you've contributed or plan to contribute
- Your GitHub username

Maintainer access is granted selectively. Even maintainers should use feature branches and pull requests — `main` is protected and requires a PR to merge.

## What we're looking for

- Bug fixes and gameplay polish
- New fruit themes or visual improvements
- Sound effects and haptics
- Accessibility improvements
- Documentation and build setup fixes

## Development setup

```bash
brew install xcodegen
xcodegen generate
open FruityMerge.xcodeproj
```

Requirements: Xcode 16+, iOS 17+ simulator or device.

## Code style

- Match existing Swift and SpriteKit patterns in the project
- Keep changes focused — one feature or fix per PR
- No third-party dependencies unless discussed in an issue first

## Questions?

Open an issue or start a discussion on GitHub. Happy merging! 🍉
