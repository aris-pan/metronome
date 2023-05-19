// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "MyLibrary",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "MainControlsFeature",
      targets: ["MainControlsFeature"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.53.2"),
  ],
  targets: [
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
      name: "AudioPlayerClient",
      dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture")]
    )
  ]
)
