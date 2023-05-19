import SwiftUI
import ComposableArchitecture
import MainControlsFeature

@main
struct MainControlsPreview: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        MainControlsView(
          store: StoreOf<MainControls>(
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
