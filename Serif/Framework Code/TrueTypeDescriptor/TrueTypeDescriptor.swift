//
//  TrueTypeDescriptor.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/23/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

// information from https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6.html

// TTF Extractor:	https://everythingfonts.com/ttfdump

// Code: http://stevehanov.ca/blog/index.php?id=143

public class TrueTypeDescriptor: FontDescriptor {
	public enum Error: Swift.Error { case noHeader, tableHeaderOutOfBounds, glyphFlagCountMismatch }

	var scalarType: UInt32 = 0
	var tableCount: UInt16 = 0
	var searchRange: UInt16 = 0
	var entrySelector: UInt16 = 0
	var rangeShift: UInt16 = 0
	var tables: [Table] = []
	
	public override var numberOfGlyphs: Int { return self.glyphs?.count ?? 0 }
	
	public var header: Header!
	public var metrics: Metrics!
	public var characterMap: CharacterMap!
	public var names: Names!
	public var locations: Locations!
	
	public override var title: String? { return self.names?.name(with: .fullName) }
	public var unitsPerEm: Int { return Int(self.header?.unitsPerEm ?? 1) }
	
	public var size: CGSize { return self.header.size }
	public var origin: CGPoint { return self.header.origin }
	public var bbox: CGRect { return self.header.bbox }
	
	public convenience init?(url: URL) {
		guard let data = try? Data(contentsOf: url) else {
			self.init(data: nil)
			return nil
		}
		
		self.init(data: data, url: url)
		do {
			try self.data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
				let array = Array(UnsafeBufferPointer(start: ptr, count: self.data.count))
				var bytes = ByteArrayParser(bytes: array, index: 0)
				try self.parse(bytes: &bytes)
			}
		} catch {
			return nil
		}
	}
	
	convenience init?(bytes: ByteArrayParser) {
		self.init(data: nil)
		
		do {
			var parser = bytes
			try self.parse(bytes: &parser)
		} catch {
			return nil
		}
	}
	
	func table(tag: Table.Tag) -> Table? {
		for table in self.tables {
			if table.tag == tag.rawValue { return table }
		}
		return nil
	}
	
	func parse(bytes: inout ByteArrayParser) throws {
		self.scalarType = try bytes.nextUInt32()
		self.tableCount = try bytes.nextUInt16()
		self.searchRange = try bytes.nextUInt16()
		self.entrySelector = try bytes.nextUInt16()
		self.rangeShift = try bytes.nextUInt16()
		
		for _ in 0..<self.tableCount {
			let tag = try bytes.nextUInt32()
			let checksum = try bytes.nextUInt32()
			let offset = Int(try bytes.nextUInt32())
			let length = Int(try bytes.nextUInt32())
			
			let info = Table(tag: tag, checksum: checksum, parser: bytes[unshifted: offset..<(offset + length)])
			
			self.tables.append(info)
		}
		
		if let header = self.table(tag: .header), let maxP = self.table(tag: .maximumProfile) {
			self.header = try Header(header: header, maxProfile: maxP)
		} else {
			throw Error.noHeader
		}
		
		if let names = self.table(tag: .names) { self.names = try Names(namesTable: names) }
		if let horiz = self.table(tag: .horizontalHeader)  { self.metrics = try Metrics(headerTable: horiz, metricsTable: self.table(tag: .horizontalMetrics)) }
		if let cmap = self.table(tag: .characterMap)  { self.characterMap = try CharacterMap(cmapTable: cmap) }
		if let loca = self.table(tag: .locations), let header = self.header { self.locations = try Locations(locaTable: loca, header: header) }
		if let glyf = self.table(tag: .glyphs), let locations = self.locations  { self.glyphs = try Glyphs(in: self, glyfTable: glyf, locations: locations) }
	}
	
	var sortedTables: [Table] {
		return self.tables.sorted { $0.parser.start < $1.parser.start }
	}
	
// MARK: Tables
	struct Table: CustomStringConvertible, CustomDebugStringConvertible {
		enum Tag: String { case header = "head", horizontalHeader = "hhea", horizontalMetrics = "hmtx", characterMap = "cmap", maximumProfile = "maxp", names = "name", controlValues = "cvt ", fontProgram = "fpgm", glyphs = "glyf", locations = "loca", postscript = "post", preparation = "prep" }
		
		let tag: String
		let checksum: UInt32
		var parser: ByteArrayParser
		
		var description: String {
			return "\(self.tag): [\(self.parser.start) -> \(self.parser.start + self.parser.count)]; \(self.parser.count) b"
		}
		var debugDescription: String { return self.description }
		
		init(platformID: UInt16, platformSpecificID: UInt16, parser: ByteArrayParser) {
			self.tag = "\(platformID),\(platformSpecificID)"
			self.checksum = 0
			self.parser = parser// ByteArrayParser(bytes: Array(bytes[Int(offset)..<Int(offset + length)]), index: 0, length: length)
		}
		
		init(tag: UInt32, checksum: UInt32, parser: ByteArrayParser) {
		//	if Int(offset + length) > bytes.count { throw Error.tableHeaderOutOfBounds }
			
			self.tag = tag.string
			self.checksum = checksum
			self.parser = parser// ByteArrayParser(bytes: Array(bytes[Int(offset)..<Int(offset + length)]), index: 0, length: length)
		}
	}
}

// MARK: UInt32 and [UInt32] extensions
extension UInt32 {
	var string: String {
		var result = ""
		
		for byte in bytes {
			result += String(Character(UnicodeScalar(byte)))
		}
		return result
	}
	
	var bytes: [UInt8] {
		var result: [UInt8] = []
		for i in [3, 2, 1, 0] {
			let byte = (self >> UInt32(i * 8)) & 0x000000FF
			result.append(UInt8(byte))
		}
		return result
	}
}

