import SwiftUI
import AppFeature

@main
struct AppFeaturePreview: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        AppView(
          store: .init(
            initialState: .init(
              songList: .init(
                songList: .init(
                  arrayLiteral: .init(id: UUID())
                )
              ),
              bpm: 70
            ),
            reducer: { AppFeature() }
          )
        )
        .navigationTitle("Metronome")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}
