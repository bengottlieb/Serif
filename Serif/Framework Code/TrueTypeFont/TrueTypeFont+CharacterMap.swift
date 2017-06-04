//
//  TrueTypeFont+CharacterMap.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/26/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension TrueTypeFont {
	public struct CharacterMap {
		let tables: [Table]
		
		init(cmapTable: Table) throws {
			var bytes = cmapTable.indexed
			
			bytes.skip(2)
			let tableCount = try bytes.nextUInt16()
			var tables: [Table] = []
			
			for _ in 0..<tableCount {
				let platformID = try bytes.nextUInt16()
				let platformSpecificID = try bytes.nextUInt16()
				let offset = try bytes.nextUInt32()
//				let nextOffset = (i < (tableCount - 1)) ? try bytes.uint32(offsetBy: 4) : UInt32(bytes.count)
//				let length = nextOffset - offset
				
				let tableInfo = Table(platformID: platformID, platformSpecificID: platformSpecificID, offset: offset, length: 0, bytes: bytes.bytes)
				tables.append(tableInfo)
			}
			self.tables = tables
		}
	}
	
	
}
