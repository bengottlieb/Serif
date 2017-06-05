//
//  TrueTypeDescriptor+Glyphs.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/26/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

// Format docs: https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6glyf.html

extension ByteArrayParser {
	mutating func nextCoordinate(with flag: UInt8, previous: Int16, isShortMask: UInt8, isSameMask: UInt8) throws -> Int16 {
		var value: Int16
		let isShortValue = (flag & isShortMask) > 0
		let isSameValue = (flag & isSameMask) > 0
		
		if isShortValue {
			value = Int16(try self.nextUInt8())
			if !isSameValue { value *= -1 }		// isSameMask is the sign bit for short coordinates
			value = previous + value
		} else {
			if isSameValue {
				value = previous
			} else {
				value = try self.nextInt16()
				value = previous + value
			}
		}
		return value
	}
}

extension TrueTypeDescriptor {	
	public class Glyphs: GlyphCollection {
		weak var font: TrueTypeDescriptor!
		
		public var count: Int { return self.glyphs.count }
		public subscript(_ index: Int) -> Glyph? {
			if index >= self.glyphs.count { return nil }
			
			if let glyph = self.glyphs[index] { return glyph }
			
			var bytes = glyfTable.parser
			bytes.jump(to: locations.offsets[index])
			do {
				var glyph = try TrueTypeGlyph(bytes, index: index)
				glyph.font = self.font
				self.glyphs[index] = glyph
				return glyph
			} catch {
				return nil
			}
		}
		
		var glyphs: [TrueTypeGlyph?]
		
		let locations: Locations
		let glyfTable: Table
		init(in font: TrueTypeDescriptor, glyfTable: Table, locations: Locations) throws {
			self.font = font
			self.glyfTable = glyfTable
			self.glyphs = [TrueTypeGlyph?](repeating: nil, count: locations.glyphCount)
			self.locations = locations
		}
		
		func validate() {
			for i in 0..<self.glyphs.count {
				if self[i] == nil {
					print("Unable to generate glyph at \(i)")
				}
			}
		}
	}

}
