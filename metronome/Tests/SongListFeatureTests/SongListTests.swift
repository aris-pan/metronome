import XCTest
import ComposableArchitecture
@testable import SongListFeature

@MainActor
final class SongListFeatureTests: XCTestCase {

  func testSongList() async {
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

  func testSongItem() async {
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
}
