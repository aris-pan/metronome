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
    case sliderDidMove(Double)
  }

  public init() {}

  struct FileNotFoundError: Error {}

  @Dependency(\.suspendingClock) var clock
  @Dependency(\.audioPlayer) var audioPlayer

  @ReducerBuilder<State, Action>
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .startTickingButtonTapped, .task:
        return .send(.startTicking)

      case .stopTickingButtonTapped:
        state.isTicking = false
        return EffectTask.cancel(id: "tickingTask")

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
        }
        .cancellable(id: "tickingTask", cancelInFlight: true)

      case .incrementButtonTapped:
        state.counter += 1
        return .none

      case .decrementButtonTapped:
        state.counter -= 1
        return .none

      case let .sliderDidMove(newValue):
        state.counter = newValue
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 48) {

        VStack(spacing: 56) {
          Text("\(Int(viewStore.state.counter))")
            .font(.init(.system(size: 80)))

          Slider(
            value: viewStore.binding(
              get: \.counter,
              send: { .sliderDidMove($0)}
            ),
            in: 20...140,
            step: 1
          ) {
            Text("bpm")
          } minimumValueLabel: {
            Text("20")
          } maximumValueLabel: {
            Text("140")
          }

          HStack {
            Button(action: {
              viewStore.send(.decrementButtonTapped)
            }) {
              Image(systemName: "minus")
                .font(.largeTitle)
                .frame(width: 10)
            }
            .padding()
            .background(Circle().stroke(style: .init()))
            Spacer()
            Button(action: {
              viewStore.send(.incrementButtonTapped)
            }) {
              Image(systemName: "plus")
                .font(.largeTitle)
                .frame(width: 10)
            }
            .padding()
            .background(Circle().stroke(style: .init()))
          }
          .padding(.horizontal, 48)
          .foregroundColor(.primary)
        }
        .padding(.horizontal, 48)

        Button(action: {
          if viewStore.state.isTicking {
            viewStore.send(.stopTickingButtonTapped)
          } else {
            viewStore.send(.startTickingButtonTapped)
          }
        }) {
          Text("\(viewStore.state.isTicking ? "STOP" : "START")")
            .frame(maxWidth: .infinity, minHeight: 40)
        }
        .padding(.horizontal, 24)
        .buttonStyle(.borderedProminent)
      }
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
