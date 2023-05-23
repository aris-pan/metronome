import SwiftUI
import ComposableArchitecture
import SongListFeature
import MainControlsFeature

public struct AppFeature: ReducerProtocol {
  public struct State: Equatable {
    var songList: SongList.State
    var mainControls: MainControls.State

    var showSongsList: Bool

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
      bpm: Double = 60,
      showSongsList: Bool = false
    ) {
      self.mainControls = mainControls
      self.songList = songList
      self.showSongsList = showSongsList
      self.bpm = bpm
    }
  }

  public enum Action {
    case mainControls(MainControls.Action)
    case songList(SongList.Action)
    case showSongsList(Bool)
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
        state.showSongsList = false
        return .none

      case .mainControls, .songList:
        return .none

      case let .showSongsList(newValue):
        state.showSongsList = newValue
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
      NavigationStack {
        VStack {
          MainControlsView(
            store: self.store.scope(
              state: \.mainControls,
              action: Action.mainControls
            )
          )
        }
        .navigationDestination(
          isPresented: viewStore.binding(
            get: \.showSongsList,
            send: { AppFeature.Action.showSongsList($0) }
          ),
          destination: {
            SongListView(
              store: self.store.scope(
                state: \.songList,
                action: Action.songList
              )
            )
          })
        .toolbar {
          Button("Songs") {
            viewStore.send(.showSongsList(true))
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
