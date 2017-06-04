//
//  TrueTypeFont+Header.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/26/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension TrueTypeFont {
	public struct Header {
		let version: CGFloat
		let fontRevision: CGFloat
		let checksumAdjustment: UInt32
		let magicNumber: UInt32
		let flags: UInt16
		let unitsPerEm: UInt16
		let created: Int64
		let modified: Int64
		let xMin: Int16
		let yMin: Int16
		let xMax: Int16
		let yMax: Int16
		let macStyle: UInt16
		let lowestRectPPEM: UInt16
		let fontDirectionHint: Int16
		let indexToLocFormat: Int16
		let glyphDataFormat: Int16
		let numberOfGlyphs: UInt16
		
		public var size: CGSize { return CGSize(width: CGFloat(self.xMax - self.xMin), height: CGFloat(self.yMax - self.yMin)) }
		public var origin: CGPoint { return CGPoint(x: CGFloat(self.xMin), y: CGFloat(self.yMin)) }
		public var bbox: CGRect { return CGRect(origin: self.origin, size: self.size) }
		
		init(header: Table, maxProfile: Table) throws {
			var bytes = header.indexed
			
			self.version = CGFloat(try bytes.nextFixed())
			self.fontRevision = CGFloat(try bytes.nextFixed())
			self.checksumAdjustment = try bytes.nextUInt32()
			self.magicNumber = try bytes.nextUInt32()
			self.flags = try bytes.nextUInt16()
			self.unitsPerEm = try bytes.nextUInt16()
			self.created = try bytes.nextInt64()
			self.modified = try bytes.nextInt64()
			self.xMin = try bytes.nextInt16()
			self.yMin = try bytes.nextInt16()
			self.xMax = try bytes.nextInt16()
			self.yMax = try bytes.nextInt16()
			self.macStyle = try bytes.nextUInt16()
			self.lowestRectPPEM = try bytes.nextUInt16()
			self.fontDirectionHint = try bytes.nextInt16()
			self.indexToLocFormat = try bytes.nextInt16()
			self.glyphDataFormat = try bytes.nextInt16()
			
			bytes = maxProfile.indexed
			bytes.skip(4)
			self.numberOfGlyphs = try bytes.nextUInt16()
			
		}
	}
	

}
