import SwiftUI
import ComposableArchitecture
import SongListFeature
import MainControlsFeature

public struct AppFeature: ReducerProtocol {
  public struct State: Equatable {
    var mainControls: MainControls.State
    var songList: SongList.State
    var path: [NavPath]

    public init(
      mainControls: MainControls.State = .init(),
      songList: SongList.State = .init(),
      path: [NavPath] = []
    ) {
      self.mainControls = mainControls
      self.songList = songList
      self.path = path
    }
  }

  public enum NavPath {
    case songList
  }

  public enum Action {
    case mainControls(MainControls.Action)
    case songList(SongList.Action)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .mainControls, .songList:
        return .none
      }
    }
    Scope(state: \.mainControls, action: /Action.mainControls) {
      MainControls()
    }
    Scope(state: \.songList, action: /Action.songList) {
      SongList()
    }

  }
}

typealias Action = AppFeature.Action

public struct AppView: View {
  var store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { _ in
      NavigationStack {
        VStack {
          MainControlsView.init(
            store: self.store.scope(
              state: \.mainControls,
              action: Action.mainControls
            )
          )
        }
        .toolbar {
          NavigationLink("Songs") {
            SongListView.init(
              store: self.store.scope(
                state: \.songList,
                action: Action.songList
              )
            )
          }
        }
      }
    }
  }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: .init(
        initialState: .init(),
        reducer: { AppFeature() }
      )
    )
  }
}
#endif
