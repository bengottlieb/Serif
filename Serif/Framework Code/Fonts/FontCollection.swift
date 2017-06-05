//
//  FontCollection.swift
//  Serif
//
//  Created by Ben Gottlieb on 6/4/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

public class FontCollection {
	public enum Error: Swift.Error { case badHeader, tableHeaderOutOfBounds }

	let data: Data!
	public var url: URL!
	public var fonts: [Font] = []

	public static func collection(at url: URL) -> FontCollection? {
		if url.pathExtension == "ttc" { return FontCollection(url: url) }
		
		if let font = Font.font(at: url) {
			return FontCollection(fonts: [font], at: url)
		}
		return nil
	}
	
	public init(data: Data!) { self.data = data }
	
	init(fonts: [Font], at url: URL) {
		self.data = nil
		self.url = url
		self.fonts = fonts
	}
	
	public convenience init?(url: URL) {
		guard let data = try? Data(contentsOf: url) else {
			self.init(data: nil)
			return nil
		}
		
		self.init(data: data)
		self.url = url
		do {
			try self.data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
				let array = Array(UnsafeBufferPointer(start: ptr, count: self.data.count))
				var bytes = ByteArrayParser(bytes: array)
				try self.parse(bytes: &bytes)
			}
		} catch {
			return nil
		}
	}
	
	func parse(bytes: inout ByteArrayParser) throws {
		let identifier = try bytes.nextUInt32().string
		
		if identifier != "ttcf" { throw Error.badHeader }
		let _ = try bytes.nextUInt16()					// major version
		let _ = try bytes.nextUInt16()					// minor version
		let fontCount = try bytes.nextUInt32()
		
		for _ in 0..<fontCount {
			let offset = Int(try bytes.nextUInt32())
			let parser = ByteArrayParser(bytes: bytes.bytes, index: offset)
			if let font = TrueTypeFont(bytes: parser) {
				self.fonts.append(font)
			}
		}
		
		
		
	}

}
