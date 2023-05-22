import XCTest
import ComposableArchitecture
@testable import MainControlsFeature
import AudioPlayerClient

@MainActor
final class MainControlsTests: XCTestCase {
  let clock = TestClock()

  func testTicking() async {
    var timesPlayed = 0

    let store = TestStore(initialState: MainControls.State()) {
      MainControls()
    } withDependencies: {
      $0.suspendingClock = self.clock
      $0.audioPlayer = .init { _ in } play: {
        timesPlayed += 1
      }
    }

    await store.send(.startTickingButtonTapped)

    await store.receive(.init(.startTicking)) {
      $0.isTicking = true
    }

    await self.clock.advance(by: .seconds(1))
    XCTAssertEqual(timesPlayed, 1)

    await self.clock.advance(by: .seconds(1))

    await store.send(.stopTickingButtonTapped) {
      $0.isTicking = false
    }

    await store.finish()
    XCTAssertEqual(timesPlayed, 2)
  }

  func testControls() async {
    let store = TestStore(initialState: MainControls.State(bpm: 50)) {
      MainControls()
    } withDependencies: {
      $0.suspendingClock = self.clock
      $0.audioPlayer = .init { _ in } play: {  }
    }

    await store.send(.decrementButtonTapped) {
      $0.bpm = 49
    }

    await store.send(.incrementButtonTapped) {
      $0.bpm = 50
    }

    await store.send(.sliderDidMove(30)) {
      $0.bpm = 30
    }

    await store.send(.decrement5ButtonTapped) {
      $0.bpm = 25
    }

    await store.send(.increment5ButtonTapped) {
      $0.bpm = 30
    }
  }

  func testMaxMinBpm() async {
    var store = TestStore(initialState: MainControls.State(bpm: 0)) {
      MainControls()
    }

    // 0 is minimum no state change
    await store.send(.decrementButtonTapped)

    store = TestStore(initialState: MainControls.State(bpm: 100)) {
      MainControls()
    }

    // 100 is maximum no state change
    await store.send(.incrementButtonTapped)
  }
}
