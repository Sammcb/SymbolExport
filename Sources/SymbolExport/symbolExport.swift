import ArgumentParser
import AppKit

@main
struct SymbolExport: ParsableCommand {
	static let configuration = CommandConfiguration(abstract: "Generates png images from SF Symbol names")

	@Argument(help: "SF Symbol name")
	var symbolName: String
	
	@Argument(help: "Output image width")
	var width: Int
	
	@Argument(help: "Output image height")
	var height: Int

	@Argument(help: "Destination folder where generated image is saved")
	var destination: String

	func validate() throws {
		guard NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) != nil else {
			throw ValidationError("'\(symbolName)' is not a valid symbol")
		}
		
		guard width > 0 else {
			throw ValidationError("Width must be greater than 0")
		}
		
		guard height > 0 else {
			throw ValidationError("Height must be greater than 0")
		}
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

			image.draw(in: imageRect, from: croppedRect, operation: .sourceOver, fraction: 1)
		}
		resized.unlockFocus()
		
		return resized.tiffRepresentation!
	}

	func run() throws {
		let fileManager = FileManager.default
		let destURL = URL(fileURLWithPath: destination, isDirectory: true)
		let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)!
		let size = NSSize(width: width, height: height)

		if !fileManager.fileExists(atPath: destURL.path) {
			try fileManager.createDirectory(at: destURL, withIntermediateDirectories: true, attributes: nil)
		}

		let symbolImage = png(image: symbol, size: size)
		fileManager.createFile(atPath: destURL.appendingPathComponent("\(symbolName).png", isDirectory: false).path, contents: symbolImage, attributes: [.extensionHidden: true])
	}
}
