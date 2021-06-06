import ArgumentParser
import AppKit

struct SymbolExport: ParsableCommand {
	static let configuration = CommandConfiguration(abstract: "Generates png images from SF Symbol names.")

	@Argument(help: "SF Symbol name.")
	var symbolName: String = "xmark" // test

	@Argument(help: "Destination folder where generated image is saved.")
	var destination: String

	func validate() throws {
		// Validate symbol name?
	}

	func png(image: NSImage, size: NSSize) -> Data {
		let imageRect = NSScreen.main!.convertRectFromBacking(NSRect(origin: .zero, size: size))
		let resized = NSImage(size: imageRect.size)
		resized.lockFocus()
		if size.width == size.height {
			image.draw(in: imageRect)
		} else {
			let landscape = size.width > size.height
			let scale = landscape ? size.width / size.height : size.height / size.width
			let croppedSize = landscape ? NSSize(width: image.size.width * scale, height: image.size.height) : NSSize(width: image.size.width, height: image.size.height * scale)
			let croppedOffset = landscape ? image.size.width - image.size.width * scale : image.size.height - image.size.height * scale
			let croppedOrigin = landscape ? CGPoint(x: croppedOffset / 2, y: 0) : CGPoint(x: 0, y: croppedOffset / 2)
			let croppedRect = CGRect(origin: croppedOrigin, size: croppedSize)

			NSColor.white.setFill()
			imageRect.fill()

			image.draw(in: imageRect, from: croppedRect, operation: .sourceOver, fraction: 1)
		}
		resized.unlockFocus()

		let alphaImage = NSBitmapImageRep(data: resized.tiffRepresentation!)!
		let opaqueImage = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: alphaImage.pixelsWide, pixelsHigh: alphaImage.pixelsHigh, bitsPerSample: alphaImage.bitsPerSample, samplesPerPixel: 3, hasAlpha: false, isPlanar: alphaImage.isPlanar, colorSpaceName: alphaImage.colorSpaceName, bytesPerRow: alphaImage.bytesPerRow, bitsPerPixel: alphaImage.bitsPerPixel)!
		for x in 0..<alphaImage.pixelsWide {
			for y in 0..<alphaImage.pixelsHigh {
				let pixelColor = alphaImage.colorAt(x: x, y: y)!
				opaqueImage.setColor(pixelColor, atX: x, y: y)
			}
		}
		return opaqueImage.representation(using: .png, properties: [:])!
	}

	func run() throws {
		let fileManager = FileManager.default
		let destURL = URL(fileURLWithPath: destination, isDirectory: true)
		let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)!
		let size = NSSize(width: 100, height: 100)

		if !fileManager.fileExists(atPath: destURL.path) {
			try fileManager.createDirectory(at: destURL, withIntermediateDirectories: true, attributes: nil)
		}

		let symbolImage = png(image: symbol, size: size)
		fileManager.createFile(atPath: destURL.appendingPathComponent("\(symbolName).png", isDirectory: false).path, contents: symbolImage, attributes: [.extensionHidden: true])
	}
}

SymbolExport.main()
