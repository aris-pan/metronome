import XCTest
import ComposableArchitecture
@testable import SongListFeature

@MainActor
final class SongListFeatureTests: XCTestCase {

  func testAddDeleteMoveSongItem() async {
    let store = TestStore(initialState: SongList.State()) {
      SongList()
    } withDependencies: {
      $0.uuid = .incrementing
    }

    await store.send(.addNewSongTapped) {
      $0.songList = [.init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)]
    }

    await store.send(.addNewSongTapped) {
      $0.songList = [
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
      ]
    }

    await store.send(.onMoveItems(IndexSet(integer: 0), 2)) {
      $0.songList = [
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!),
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
      ]
    }

    await store.send(.onDeleteSong(IndexSet(integer: 1))) {
      $0.songList = [.init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)]
    }
  }

  func testEditSongItem() async {
    let store = TestStore(initialState: SongList.State(songList: [
      .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
    ])) {
      SongList()
    }

    await store.send(.todo(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
      action: .textFieldChanged("Snap Out Of It")
    )) {
      $0.songList = [
        .init(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          title: "Snap Out Of It"
        )
      ]
    }

    await store.send(.todo(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
      action: .bpmFieldChanged("55")
    )) {
      $0.songList = [
        .init(
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          title: "Snap Out Of It",
          bpm: "55"
        )
      ]
    }
  }

  func testSaveLoadSongList() async {
    let initialSongList: IdentifiedArrayOf<SongItem.State> = [
      .init(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        title: "Snap Out Of It",
        bpm: "98"
      ),
      .init(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        title: "About A Girl",
        bpm: "88"
      )
    ]

    var savedData: Data?
    var savedURL: URL?
    var loadURL: URL?

    let store = TestStore(initialState: SongList.State(songList: initialSongList)) {
      SongList()
    } withDependencies: {
      $0.fileManager = FileManagerClient(
        save: { data, url in
          savedData = data
          savedURL = url
      }, load: { url in
        loadURL = url
        return savedData!
      })
    }

    await store.send(.saveButtonTapped)

    // swiftlint:disable:next compiler_protocol_init
    await store.send(.onDeleteSong(IndexSet(arrayLiteral: 0, 1))) {
      $0.songList = []
    }

    await store.send(.loadButtonTapped) {
      $0.songList = initialSongList
    }

    XCTAssertEqual(loadURL, URL.documentsDirectory.appending(path: "metronome_song_list"))
    XCTAssertEqual(savedURL, URL.documentsDirectory.appending(path: "metronome_song_list"))
  }
}
