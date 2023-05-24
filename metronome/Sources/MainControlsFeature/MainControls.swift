import SwiftUI
import Combine
import ComposableArchitecture
import AudioPlayerClient

public struct MainControls: ReducerProtocol {
  public struct State: Equatable {

    var minBPM: Double
    var maxBPM: Double

    public var isTicking: Bool
    public var bpm: Double {
      didSet {
        bpm = min(max(bpm, minBPM), maxBPM)
      }
    }

    var tickingInterval: Double {
      Double(60) / Double(bpm)
    }

    public init(
      bpm: Double = 0,
      isTicking: Bool = false,
      minBPM: Double = 10,
      maxBPM: Double = 140
    ) {
      self.minBPM = minBPM
      self.maxBPM = maxBPM
      self.bpm = bpm
      self.isTicking = isTicking
    }
  }

  public enum Action {
    case startTickingButtonTapped
    case stopTickingButtonTapped
    case startTicking

    case incrementButtonTapped
    case decrementButtonTapped
    case decrement5ButtonTapped
    case increment5ButtonTapped
    case sliderDidMove(Double)
    case didChangeBPM
  }

  public init() {}

  struct FileNotFoundError: Error {}

  @Dependency(\.suspendingClock) var clock
  @Dependency(\.audioPlayer) var audioPlayer

  @ReducerBuilder<State, Action>
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      struct TickingEffectId: Hashable {}

      switch action {
      case .startTickingButtonTapped:
        return .send(.startTicking)

      case .stopTickingButtonTapped:
        state.isTicking = false
        return EffectTask.cancel(id: TickingEffectId())

      case .startTicking:
        state.isTicking = true
        return .run { [tickingInterval = state.tickingInterval] _ in
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
        .cancellable(id: TickingEffectId(), cancelInFlight: true)

      case .incrementButtonTapped:
        state.bpm += 1
        return .send(.didChangeBPM)

      case .decrementButtonTapped:
        state.bpm -= 1
        return .send(.didChangeBPM)

      case let .sliderDidMove(newValue):
        state.bpm = newValue
        return .send(.didChangeBPM)

      case .decrement5ButtonTapped:
        state.bpm -= 5
        return .send(.didChangeBPM)

      case .increment5ButtonTapped:
        state.bpm += 5
        return .send(.didChangeBPM)

      case .didChangeBPM:
        if state.isTicking {
          return .send(.startTicking)
        } else {
          return .none
        }
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
        HStack {
          Text("\(Int(viewStore.state.bpm))")
            .font(.init(.system(size: 80)))
          Text("bpm")
        }
        Slider(
          value: viewStore.binding(
            get: \.bpm,
            send: MainControls.Action.sliderDidMove
          ),
          in: viewStore.state.minBPM...viewStore.state.maxBPM,
          step: 1
        ) {
          Text("bpm")
        } minimumValueLabel: {
          Text("\(Int(viewStore.state.minBPM))")
        } maximumValueLabel: {
          Text("\(Int(viewStore.state.maxBPM))")
        }

        VStack {
          HStack {
            Button("-5") {
              viewStore.send(.decrement5ButtonTapped)
            }
            Spacer()
            Button("+5") {
              viewStore.send(.increment5ButtonTapped)
            }
          }
          HStack {
            Button("-1") {
              viewStore.send(.decrementButtonTapped)
            }
            Spacer()
            Button("+1") {
              viewStore.send(.incrementButtonTapped)
            }
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
          HStack {
            Text("\(viewStore.state.isTicking ? "STOP" : "START")")
            Image(systemName: "\(viewStore.state.isTicking ? "pause" : "play")")
          }
          .frame(maxWidth: .infinity, minHeight: 40)
        }
        .buttonStyle(.borderedProminent)
      }
      .padding(.horizontal, 48)
    }
  }
}

#if DEBUG
struct MainControls_Previews: PreviewProvider {
  static var previews: some View {
    MainControlsView(
      store: Store(
        initialState: MainControls.State(bpm: 70),
        reducer: MainControls(),
        prepareDependencies: {
          $0.audioPlayer = .liveValue
        }
      )
    )
  }
}
#endif
