import SwiftUI

@main
struct FruityMergeApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
        }
    }
}

struct GameView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        GameViewController()
    }
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {}
}
