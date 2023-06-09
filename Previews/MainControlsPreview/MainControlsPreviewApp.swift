import SwiftUI
import MainControlsFeature

@main
struct MainControlsPreview: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        MainControlsView(
          store: .init(
            initialState: .init(),
            reducer: MainControls()
          )
        )
        .navigationTitle("Metronome")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}
