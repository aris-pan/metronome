import Foundation
import ComposableArchitecture

public struct AudioPlayerClient {
  public var setUrl: (URL) -> Void
  public var play: () -> Void

  public init(
    setUrl: @escaping (URL) -> Void,
    play: @escaping () -> Void) {
    self.setUrl = setUrl
    self.play = play
  }
}

extension DependencyValues {
  public var audioPlayer: AudioPlayerClient {
    get { self[AudioPlayerClient.self] }
    set { self[AudioPlayerClient.self] = newValue }
  }
}

extension AudioPlayerClient: DependencyKey {
  public static var liveValue: AudioPlayerClient = .live

  public static var testValue: AudioPlayerClient = .test
  public static var previewValue: AudioPlayerClient = .test
}

// MARK: - Test Value

extension AudioPlayerClient {
  static let test: AudioPlayerClient = Self(
    setUrl: unimplemented("AudioPlayerClient.setUrl"),
    play: unimplemented("AudioPlayerClient.play")
  )
}

// MARK: - Live Value

import AVFoundation

extension AudioPlayerClient {
  static let live: AudioPlayerClient = {
    var audioPlayer: AVAudioPlayer?

    return Self(
      setUrl: { url in
        do {
          audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
          // TODO: Add Logging
          print("Error: Audio Player Could not open file at \(url)")
        }
      },
      play: {
        guard let audioPlayer else {
          print("Error: Audio Player Could not be found")
          return
        }

        audioPlayer.play()
      }
    )
  }()
}
