//
//  TrueTypeFont+CharacterMap.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/26/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension TrueTypeDescriptor {
	public struct CharacterMap {
		let subtables: [Subtable]
		
		enum Platform: UInt16 { case unicode = 0, mac = 1, microsoft = 3, unknown }
		
		struct Subtable {
			let platform: Platform
			let platformSpecific: Int
			let parser: ByteArrayParser
		}
		
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
			
			self.subtables = tables
		}
	}
	
	
}
