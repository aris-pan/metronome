import SwiftUI
import Combine
import ComposableArchitecture
import AudioPlayerClient

public struct MainControls: ReducerProtocol {
  public struct State: Equatable {

    var isTicking: Bool
    var counter: Double
    var tickingInterval: Double {
      Double(60) / Double(counter)
    }

    public init(
      counter: Double = 70,
      isTicking: Bool = false
    ) {
      self.counter = counter
      self.isTicking = isTicking
    }
  }

  public enum Action {
    case startTickingButtonTapped
    case stopTickingButtonTapped
    case task
    case startTicking

    case incrementButtonTapped
    case decrementButtonTapped
    case decrement5ButtonTapped
    case increment5ButtonTapped
    case sliderDidMove(Double)
  }

  public init() {}

  struct FileNotFoundError: Error {}

  @Dependency(\.suspendingClock) var clock
  @Dependency(\.audioPlayer) var audioPlayer
  @Dependency(\.mainQueue) var mainQueue

  @ReducerBuilder<State, Action>
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      struct TickingEffectId: Hashable {}

      switch action {
      case .startTickingButtonTapped, .task:
        return .send(.startTicking)

      case .stopTickingButtonTapped:
        state.isTicking = false
        return EffectTask.cancel(id: TickingEffectId())

      case .startTicking:
        state.isTicking = true
        return .run { [tickingInterval = state.tickingInterval] send in
          let clock: AsyncStream = clock.timer(
            interval: .seconds(tickingInterval)
          ).eraseToStream()

          guard let url = Bundle.module
            .url(forResource: "click.wav", withExtension: nil) else {
            throw FileNotFoundError()
          }
          audioPlayer.setUrl(url)

          for await _ in clock {
            audioPlayer.play()
          }
        }.debounce(id: TickingEffectId(), for: 0.4, scheduler: mainQueue)
        .cancellable(id: TickingEffectId(), cancelInFlight: true)

      case .incrementButtonTapped:
        state.counter += 1
        return .none

      case .decrementButtonTapped:
        state.counter -= 1
        return .none

      case let .sliderDidMove(newValue):
        state.counter = newValue
        return .none
      case .decrement5ButtonTapped:
        state.counter -= 5
        return .none

      case .increment5ButtonTapped:
        state.counter += 5
        return .none
      }
    }
  }
}

public struct MainControlsView: View {
  var store: StoreOf<MainControls>

  public init(store: StoreOf<MainControls>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 48) {
        Text("\(Int(viewStore.state.counter))")
          .font(.init(.system(size: 80)))

        Slider(
          value: viewStore.binding(
            get: \.counter,
            send: MainControls.Action.sliderDidMove
          ),
          in: 20...140,
          step: 1
        ) { Text("bpm")
        } minimumValueLabel: { Text("20")
        } maximumValueLabel: { Text("140") }

        VStack {
          HStack {
            Button(action: {
              viewStore.send(.decrement5ButtonTapped)
            }) { Text("-5") }
            Spacer()
            Button(action: {
              viewStore.send(.increment5ButtonTapped)
            }) { Text("+5") }
          }
          HStack {
            Button(action: {
              viewStore.send(.decrementButtonTapped)
            }) { Text("-1") }
            Spacer()
            Button(action: {
              viewStore.send(.incrementButtonTapped)
            }) { Text("+1") }
          }
        }
        .buttonStyle(.borderedProminent)

        Button {
          if viewStore.state.isTicking {
            viewStore.send(.stopTickingButtonTapped)
          } else {
            viewStore.send(.startTickingButtonTapped)
          }
        } label: {
          Label("\(viewStore.state.isTicking ? "STOP" : "START")",
                systemImage: "\(viewStore.state.isTicking ? "pause" : "play")")
          .frame(maxWidth: .infinity, minHeight: 40)
        }
        .buttonStyle(.borderedProminent)
      }
      .padding(.horizontal, 48)
      .task {
        viewStore.send(.task)
      }
    }
  }
}

#if DEBUG
struct MainControls_Previews: PreviewProvider {
  static var previews: some View {
    MainControlsView(
      store: Store(
        initialState: MainControls.State(),
        reducer: MainControls()
      )
    )
  }
}
#endif
