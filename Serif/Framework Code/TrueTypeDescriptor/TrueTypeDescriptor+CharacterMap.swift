//
//  TrueTypeFont+CharacterMap.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/26/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension TrueTypeDescriptor {
	public struct TrueTypeCharacterMap: CharacterMap {
		enum Error: Swift.Error { case noCharacterMapFind }
		
		let subtables: [Subtable]
		
		enum Platform: UInt16 { case unicode = 0, mac = 1, microsoft = 3, unknown }
		
		public func map(cid: Int) -> Int? { return self.primaryTable?.map(cid: cid) }
		public func map(gid: Int) -> Int? { return self.primaryTable?.map(gid: gid) }

		struct Subtable {
			let platform: Platform
			let platformSpecific: Int
			var parser: ByteArrayParser
			var mapping: [Int] = []
			
			
			init(platform: Platform, platformSpecific: Int, parser: ByteArrayParser) {
				self.platform = platform
				self.platformSpecific = platformSpecific
				self.parser = parser
			}
			
			mutating func parse() throws {
				let version = try self.parser.nextUInt16()
				_ = self.parser.skip(2)		// size
				_ = self.parser.skip(2)		// language code
				
				switch version {
				case 0:
					for _ in 0..<256 {
						self.mapping.append(Int(try self.parser.nextUInt8()))
					}
					
				default: break
				}
			}
			
			func map(cid: Int) -> Int? {
				if cid < self.mapping.count { return self.mapping[cid] }
				return nil
			}
			
			func map(gid: Int) -> Int? {
				for i in 0..<self.mapping.count {
					if self.mapping[i] == gid { return i }
				}
				return nil
			}
		}
		
		var primaryTable: Subtable!
		
		init(cmapTable: Table) throws {
			var bytes = cmapTable.parser
			
			bytes.skip(2)								//version, should always be 0
			let tableCount = try bytes.nextUInt16()
			var tableOffsets: [(platformID: Platform, platformSpecificID: Int, offset: Int)] = []
			
			for _ in 0..<tableCount {
				let platformID = Platform(rawValue: try bytes.nextUInt16()) ?? .unknown
				let platformSpecificID = Int(try bytes.nextUInt16())
				let offset = try bytes.nextUInt32()
				
				tableOffsets.append((platformID: platformID, platformSpecificID: Int(platformSpecificID), offset: Int(offset)))
//				let nextOffset = (i < (tableCount - 1)) ? try bytes.uint32(offsetBy: 4) : UInt32(bytes.count)
//				let length = nextOffset - offset
				
//				let tableInfo = Table(platformID: platformID, platformSpecificID: platformSpecificID, parser: bytes[offset..<offset])
//				tables.append(tableInfo)
			}
			
			tableOffsets = tableOffsets.sorted { $0.offset < $1.offset }
			var tables: [Subtable] = []
			for i in 0..<tableOffsets.count {
				let current = tableOffsets[i]
				let nextOffset = (i < (tableOffsets.count - 1)) ? tableOffsets[i + 1].offset : bytes.count
				let tableInfo = Subtable(platform: current.platformID, platformSpecific: current.platformSpecificID, parser: bytes[current.offset..<nextOffset])
				tables.append(tableInfo)
			}
			
			self.subtables = tables.sorted { cmap1, cmap2 in
				if cmap1.platform == .mac { return true }
				if cmap1.platform == .unicode { return true }
				return false
			}
			
			self.primaryTable = self.subtables.first
			guard self.primaryTable != nil else { throw Error.noCharacterMapFind }
			
			try self.primaryTable.parse()
		}
		
		
	}
}
