import SwiftUI
import ComposableArchitecture
import SongListFeature
import MainControlsFeature

public struct AppFeature: ReducerProtocol {
  public struct State: Equatable {
    var songList: SongList.State
    var mainControls: MainControls.State
    var path: [Nav]

    // Add a view of the bpm LocalState
    var bpm: Double {
      get { mainControls.bpm }
      set {
        mainControls = MainControls.State(
          bpm: newValue,
          isTicking: mainControls.isTicking
        )
      }
    }

    public init(
      mainControls: MainControls.State = .init(),
      songList: SongList.State = .init(),
      path: [Nav] = [],
      bpm: Double = 60
    ) {
      self.mainControls = mainControls
      self.songList = songList
      self.path = path
      self.bpm = bpm
    }
  }

  public enum Nav: Hashable {
    case songList
  }

  public enum Action {
    case mainControls(MainControls.Action)
    case songList(SongList.Action)
    case pathUpdated([Nav])
    case songsButtonTapped
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.mainControls, action: /Action.mainControls) {
      MainControls()
    }
    Scope(state: \.songList, action: /Action.songList) {
      SongList()
    }
    Reduce { state, action in
      switch action {
      case let .songList(.song(_, action: .setButtonTapped(stringBpm))):
        guard let bpm = Double(stringBpm) else {
          return .none
        }
        state.bpm = bpm
        state.path.removeLast()
        return .none

      case .mainControls, .songList:
        return .none

      case let .pathUpdated(path):
        state.path = path
        return .none

      case .songsButtonTapped:
        state.path.append(.songList)
        return .none
      }
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
    WithViewStore(store) { viewStore in
      NavigationStack(path: viewStore.binding(
        get: \.path,
        send: AppFeature.Action.pathUpdated
      )) {
        VStack {
          MainControlsView(
            store: self.store.scope(
              state: \.mainControls,
              action: Action.mainControls
            )
          )
        }
        .navigationDestination(for: AppFeature.Nav.self) { route in
          switch route {
          case .songList:
            SongListView(
              store: self.store.scope(
                state: \.songList,
                action: Action.songList
              )
            )
          }
        }
        .toolbar {
          Button("Songs") {
            viewStore.send(.songsButtonTapped)
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
        initialState: .init(
          songList: SongList.State(
            songList: IdentifiedArray(
              uniqueElements: [
                .init(id: UUID(), title: "About A Girl", bpm: "81"),
                .init(id: UUID(), title: "Snap Out Of It", bpm: "76")
              ]
            )
          ),
          bpm: 70
        ),
        reducer: { AppFeature() }
      )
    )
  }
}
#endif
