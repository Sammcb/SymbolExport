// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "SymbolExport",
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
	],
	targets: [
		.target(
			name: "SymbolExport",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]),
		.testTarget(
			name: "SymbolExportTests",
			dependencies: ["SymbolExport"]),
	]
)