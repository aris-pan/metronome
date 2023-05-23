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
    case song(id: UUID, action: SongItem.Action)
    case saveButtonTapped
    case loadButtonTapped
  }

  @Dependency(\.uuid) var uuid
  @Dependency(\.fileManager) var fileManager

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .addNewSongTapped:
        state.songList.append(SongItem.State(id: uuid()))
        return .none

      case let .onDeleteSong(indexSet):
        state.songList.remove(atOffsets: indexSet)
        return .none

      case let .onMoveItems(indices, newOffset):
        state.songList.move(fromOffsets: indices, toOffset: newOffset)
        return .none

      case .song:
        return .none
      case .saveButtonTapped:
        do {
          let dataSongList = try JSONEncoder().encode(state.songList)
          try fileManager.save(dataSongList, URL.songListPath)
        } catch {
          // TODO: Add error handling
        }
        return .none

      case .loadButtonTapped:
        do {
          let dataSongList = try fileManager.load(URL.songListPath)
          let songList = try JSONDecoder().decode([SongItem.State].self, from: dataSongList)
          state.songList = IdentifiedArray(uniqueElements: songList)
        } catch {
          // TODO: Add error handling
        }
        return .none
      }
    }
    .forEach(\.songList, action: /Action.song(id:action:)) {
      SongItem()
    }
  }
}

extension URL {
  static let songListPath: URL = .documentsDirectory.appending(path: "metronome_song_list")
}

public struct SongListView: View {
  var store: StoreOf<SongList>

  public init(store: StoreOf<SongList>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      List {
        ForEachStore(
          self.store.scope(
            state: \.songList,
            action: SongList.Action.song(id:action:)),
          content: SongItemView.init(store:)
        )
        .onDelete { viewStore.send(.onDeleteSong($0)) }
        .onMove { viewStore.send(.onMoveItems($0, $1)) }

        Button {
          viewStore.send(.addNewSongTapped, animation: .easeIn)
        } label: {
          Text("Add")
          Image(systemName: "plus.circle")
        }
      }
      // Makes buttons inside List tappable
      .buttonStyle(BorderlessButtonStyle())
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu(content: {
            Button("Load") {
              viewStore.send(.loadButtonTapped)
            }
            Button("Save") {
              viewStore.send(.saveButtonTapped)
            }
            EditButton()
          }, label: { Image(systemName: "ellipsis") })
        }
      }
      .navigationTitle("Song List")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

public struct SongItem: ReducerProtocol {
  public struct State: Equatable, Identifiable, Codable {
    public let id: UUID
    var title: String
    var bpm: String

    public init(
      id: UUID,
      title: String = "",
      bpm: String = ""
    ) {
      self.id = id
      self.title = title
      self.bpm = bpm
    }
  }

  public enum Action: Equatable {
    case textFieldChanged(String)
    case bpmFieldChanged(String)
    case setButtonTapped(String)
  }

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .textFieldChanged(let text):
      state.title = text
      return .none

    case let .bpmFieldChanged(newBpm):
      guard newBpm.count <= 3 else {
        return .none
      }
      state.bpm = newBpm
      return .none

    case .setButtonTapped(_):
      return .none
    }
  }
}

struct SongItemView: View {
  let store: StoreOf<SongItem>

  var body: some View {
    WithViewStore(store) { viewStore in
      HStack(spacing: 32) {
        TextField(
          "Song Title",
          text: viewStore.binding(
            get: \.title,
            send: SongItem.Action.textFieldChanged
          )
        )
        TextField(
          "bpm",
          text: viewStore.binding(
            get: \.bpm,
            send: SongItem.Action.bpmFieldChanged
          )
        )
        .frame(width: 40)
        .keyboardType(.decimalPad)

        Button("Set") {
          viewStore.send(.setButtonTapped(viewStore.state.bpm))
        }
        .disabled(viewStore.bpm.isEmpty)
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
            .init(
              id: UUID(),
              title: "I Fought the Law",
              bpm: "110"
            ),
            .init(
              id: UUID(),
              title: "",
              bpm: ""
            )
          ]),
          reducer: SongList()
        )
      )
    }
  }
}
#endif
