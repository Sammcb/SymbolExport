// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "SymbolExport",
	platforms: [
		.macOS(.v11)
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
	],
	targets: [
		.target(
			name: "SymbolExport",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]),
	]
)
