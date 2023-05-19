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
    let store = TestStore(initialState: MainControls.State(counter: 50)) {
      MainControls()
    }

    await store.send(.decrementButtonTapped) {
      $0.counter = 49
    }

    await store.send(.incrementButtonTapped) {
      $0.counter = 50
    }

    await store.send(.sliderDidMove(30)) {
      $0.counter = 30
    }
  }
}
