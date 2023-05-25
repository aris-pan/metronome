import XCTest
import ComposableArchitecture
@testable import MainControlsFeature
import AudioPlayerClient

@MainActor
final class MainControlsTests: XCTestCase {
  let clock = TestClock()

  func testTicking() async {
    var timesPlayed = 0

    let store = TestStore(initialState: MainControls.State(bpm: 60)) {
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

    await store.send(.decrementButtonTapped)

    await store.receive(.init(.checkIfBpmShouldChange(-1))) {
      $0.bpm = 49
    }

    await store.send(.incrementButtonTapped)

    await store.receive(.init(.checkIfBpmShouldChange(50))) {
      $0.bpm = 50
    }

    await store.send(.sliderDidMove(30))

    await store.receive(.init(.checkIfBpmShouldChange(30))) {
      $0.bpm = 30
    }

    await store.send(.decrement5ButtonTapped)

    await store.receive(.init(.checkIfBpmShouldChange(25))) {
      $0.bpm = 25
    }

    await store.send(.increment5ButtonTapped)

    await store.receive(.init(.checkIfBpmShouldChange(30))) {
      $0.bpm = 30
    }

    await store.send(.startTickingButtonTapped)

    await store.receive(.init(.startTicking)) {
      $0.isTicking = true
    }

    await store.send(.increment5ButtonTapped)

    await store.receive(.init(.checkIfBpmShouldChange(35))) {
      $0.bpm = 35
    }

    await store.receive(.init(.startTicking))

    await store.send(.stopTickingButtonTapped) {
      $0.isTicking = false
    }
  }

  func testMaxMinBpm() async {
    var store = TestStore(initialState: MainControls.State(bpm: 10, minBPM: 10, maxBPM: 100)) {
      MainControls()
    }

    await store.send(.decrementButtonTapped)

    // 10 is minimum no state change
    await store.receive(.init(.checkIfBpmShouldChange(9)))

    store = TestStore(initialState: MainControls.State(bpm: 100, minBPM: 10, maxBPM: 100)) {
      MainControls()
    }

    await store.send(.incrementButtonTapped)

    // 100 is maximum no state change
    await store.receive(.init(.checkIfBpmShouldChange(101)))
  }
}
