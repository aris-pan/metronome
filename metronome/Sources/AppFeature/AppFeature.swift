import SwiftUI
import ComposableArchitecture
import SongListFeature
import MainControlsFeature

struct AppFeature: ReducerProtocol {
  struct State: Equatable {
    var mainControls: MainControls.State
    var songList: SongList.State
    var path: [NavPath]

    init(
      mainControls: MainControls.State = .init(),
      songList: SongList.State = .init(),
      path: [NavPath] = []
    ) {
      self.mainControls = mainControls
      self.songList = songList
      self.path = path
    }
  }

  enum NavPath {
    case songList
  }

  enum Action {
    case mainControls(MainControls.Action)
    case songList(SongList.Action)
    case songListPathChanged([NavPath])
    case songListButtonTapped
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .mainControls, .songList:
        return .none

      case let .songListPathChanged(newNavPath):
        state.path = newNavPath
        return .none

      case .songListButtonTapped:
        state.path.append(.songList)
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

struct AppView: View {
  var store: StoreOf<AppFeature>

  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStack(
        path: viewStore.binding(
          get: { _ in viewStore.path },
          send: .songListPathChanged(viewStore.path)
        )
      ) {
        VStack {
          MainControlsView.init(
            store: self.store.scope(
              state: \.mainControls,
              action: Action.mainControls
            )
          )
        }
        .toolbar {
          Button("Song List") {
            viewStore.send(.songListButtonTapped)
          }
        }
        .navigationDestination(for: AppFeature.NavPath.self) { navPath in
          switch navPath {
          case .songList:
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
