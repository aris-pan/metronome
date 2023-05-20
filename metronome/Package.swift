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
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SongListFeature",
        "MainControlsFeature"
      ]
    ),

    .target(
      name: "MainControlsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "AudioPlayerClient"
      ],
      resources: [.process("click.wav")]
    ),
    .testTarget(
      name: "MainControlsFeatureTests",
      dependencies: ["MainControlsFeature"]
    ),

    .target(
      name: "SongListFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "SongListFeatureTests",
      dependencies: ["SongListFeature"]
    ),

    .target(
      name: "AudioPlayerClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
  ]
)
