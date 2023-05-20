// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "metronome",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "SongListFeature", targets: ["SongListFeature"]),
    .library(name: "MainControlsFeature", targets: ["MainControlsFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.53.2"),
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.52.2"),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SongListFeature",
        "MainControlsFeature"
      ],
      plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
    ),

    .target(
      name: "MainControlsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "AudioPlayerClient"
      ],
      resources: [.process("click.wav")],
      plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
    ),
    .testTarget(
      name: "MainControlsFeatureTests",
      dependencies: ["MainControlsFeature"],
      plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
    ),

    .target(
      name: "SongListFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
    ),
    .testTarget(
      name: "SongListFeatureTests",
      dependencies: ["SongListFeature"],
      plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
    ),

    .target(
      name: "AudioPlayerClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
    ),
  ]
)
