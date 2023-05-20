import SwiftUI
import AppFeature

@main
struct AppFeaturePreview: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        AppView(
          store: .init(
            initialState: .init(),
            reducer: AppFeature()
          )
        )
        .navigationTitle("Metronome")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}
