import Foundation
import ComposableArchitecture

public struct FileManagerClient {
  public var save: (Data, URL) throws -> Void
  public var load: (URL) throws -> Data
}

extension FileManagerClient: DependencyKey {
  public static var liveValue: Self = .live

  public static var testValue: Self = .test
  public static var previewValue: Self = .test
}

// MARK: - Live Value

extension FileManagerClient {
  static let live = Self(
    save: { data, url in
      try data.write(to: url)
    },
    load: { url in
      try Data(contentsOf: url)
    }
  )
}

// MARK: - Test Value

extension FileManagerClient {
  static let test = Self (
    save: unimplemented("FileManagerClient.save"),
    load: unimplemented("FileManagerClient.load")
  )
}

extension DependencyValues {
  public var fileManager: FileManagerClient {
    get { self[FileManagerClient.self] }
    set { self[FileManagerClient.self] = newValue }
  }
}
