// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "MyLibrary",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "MetronomeFeature",
      targets: ["MetronomeFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.53.2"),
  ],
  targets: [
    .target(
      name: "MetronomeFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]),
  ]
)
