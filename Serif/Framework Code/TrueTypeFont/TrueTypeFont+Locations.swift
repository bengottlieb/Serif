//
//  TrueTypeFont+Locations.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/29/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension TrueTypeFont {
	public struct Locations {
		let offsets: [Int]
		let glyphCount: Int
		
		init(locaTable: Table, header: Header) throws {
			var bytes = locaTable.parser
			var offsets: [Int] = []
			
			if header.indexToLocFormat == 0 {			//UInt16 offsets
				for _ in 0..<header.numberOfGlyphs {
					offsets.append(Int(try bytes.nextUInt16()) * 2)
				}
			} else {
				for _ in 0..<header.numberOfGlyphs {
					offsets.append(Int(try bytes.nextUInt32()))
				}
			}
			
			self.glyphCount = Int(header.numberOfGlyphs)
			self.offsets = offsets
		}
	}
}
