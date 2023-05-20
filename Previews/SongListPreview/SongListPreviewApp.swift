import SwiftUI
import SongListFeature

@main
struct SongListPreview: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        SongListView(
          store: .init(
            initialState: .init(),
            reducer: SongList()
          )
        )
        .navigationTitle("Song List")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}
