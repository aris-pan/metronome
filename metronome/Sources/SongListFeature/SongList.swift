import ComposableArchitecture
import SwiftUI

public struct SongList: ReducerProtocol {
  public struct State: Equatable {
    var songList: IdentifiedArrayOf<SongItem.State>

    public init(songList: IdentifiedArrayOf<SongItem.State> = []) {
      self.songList = songList
    }
  }

  public enum Action: Equatable {
    case addNewSongTapped
    case onDeleteSong(IndexSet)
    case onMoveItems(IndexSet, Int)
    case todo(id: SongItem.State.ID, action: SongItem.Action)
  }

  @Dependency(\.uuid) var uuid

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .addNewSongTapped:
        state.songList.append(SongItem.State(title: "", id: uuid(), bpm: ""))
        return .none
        
      case let .onDeleteSong(indexSet):
        state.songList.remove(atOffsets: indexSet)
        return .none
        
      case let .onMoveItems(indeces, newOffset):
        state.songList.move(fromOffsets: indeces, toOffset: newOffset)
        return .none

      case .todo:
        return .none
      }
    }
    .forEach(\.songList, action: /Action.todo(id:action:)) {
      SongItem()
    }
  }
}

public struct SongListView: View {
  var store: StoreOf<SongList>

  public init(store: StoreOf<SongList>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Form {
        List {
          Section(header: HStack {
            Text("Songs")
            Image(systemName: "music.note")
          }){
            ForEachStore(
              self.store.scope(
                state: \.songList,
                action: SongList.Action.todo(id:action:)),
              content: SongItemView.init(store:)
            )
            .onDelete { viewStore.send(.onDeleteSong($0)) }
            .onMove { indexes, newOffset in
              viewStore.send(.onMoveItems(indexes, newOffset))
            }
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          EditButton()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Add") {
            viewStore.send(.addNewSongTapped)
          }
        }
      }
    }
  }
}

public struct SongItem: ReducerProtocol {
  public struct State: Equatable, Identifiable {
    var title = ""
    public let id: UUID
    var bpm = ""
  }

  public enum Action: Equatable {
    case textFieldChanged(String)
    case bpmFieldChanged(String)
  }

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .textFieldChanged(let text):
      state.title = text
      return .none

    case let .bpmFieldChanged(bpm):
      guard bpm.count <= 3 else {
        return .none
      }
      state.bpm = bpm
      return .none
    }
  }
}

struct SongItemView: View {
  let store: StoreOf<SongItem>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack {
          TextField(
            "Song Title",
            text: viewStore.binding(
              get: \.title,
              send: SongItem.Action.textFieldChanged
            )
          )
          Spacer()
          TextField(
            "bpm",
            text: viewStore.binding(
              get: \.bpm,
              send: SongItem.Action.bpmFieldChanged
            )
          )

          .frame(width: 35)
          .keyboardType(.decimalPad)
        }
    }
  }
}


#if DEBUG
struct SongListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SongListView(
        store: Store(
          initialState: SongList.State(songList: [
            .init(title: "I Fought the Law", id: UUID(), bpm: "110"),
            .init(title: "Gigantic", id: UUID(), bpm: "65")
          ]),
          reducer: SongList()
        )
      )
    }
  }
}
#endif
