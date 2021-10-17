// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "Atsani",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "Atsani", targets: ["Atsani"]),
  ],
  targets: [
    .target(name: "Atsani", path: "Sources")
  ],
  swiftLanguageVersions: [
    .v5
  ]
)

