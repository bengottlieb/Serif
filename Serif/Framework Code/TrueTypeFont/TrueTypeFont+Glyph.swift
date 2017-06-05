//
//  TrueTypeFont+Glyph.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/30/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation
import AppKit
import CrossPlatformKit

extension TrueTypeFont {
	public struct Glyph: CustomStringConvertible {
		struct Component {
			var ctm = CGAffineTransform()
			var index = 0
			var sourcePointIndex = 0
			var destinationPointIndex = 0
		}
		
		struct Point {
			var x: Int16
			var y: Int16
			let isOnCurve: Bool
			let isContourEnd: Bool
			
			var point: CGPoint { return CGPoint(x: Int(self.x), y: Int(self.y)) }
		}
		
		public var description: String {
			var result = "(\(self.xMin), \(self.yMin)) -> (\(self.xMax), \(self.yMax)), \(self.instructions?.count ?? 0) bytes inst.: ["
			for point in self.points ?? [] {
				result += "(\(point.x), \(point.y)), "
			}
			result += "]"
			return result
		}
		
		public let numberOfContours: Int
		public var size: CGSize { return CGSize(width: CGFloat(self.xMax - self.xMin), height: CGFloat(self.yMax - self.yMin)) }
		public var origin: CGPoint { return CGPoint(x: CGFloat(self.xMin), y: CGFloat(self.yMin)) }
		public var bbox: CGRect { return CGRect(origin: self.origin, size: self.size) }
		public let index: Int
		
		let xMin: Int16
		let yMin: Int16
		let xMax: Int16
		let yMax: Int16
		let instructions: [UInt8]?
		let points: [Point]?
		let components: [Component]?
		weak var font: TrueTypeFont!
		
		init(_ incoming: ByteArrayParser, index: Int) throws {
			self.index = index
			var bytes = incoming
			let count = try bytes.nextInt16()
			self.numberOfContours = Int(abs(count))
			
			self.xMin = try bytes.nextInt16()
			self.yMin = try bytes.nextInt16()
			self.xMax = try bytes.nextInt16()
			self.yMax = try bytes.nextInt16()
			
			if count > 0 {				// simple Glyph
				var endpoints: [UInt16] = []
				
				for _ in 0..<self.numberOfContours {
					endpoints.append(try bytes.nextUInt16())
				}
				
				let instructionLength = try bytes.nextUInt16()
				self.instructions = try bytes.getNext(n: Int(instructionLength))
				
				if let lastCoordinateIndex = endpoints.last {
					let coordinateCount = Int(lastCoordinateIndex + 1)
					
					var flags: [UInt8] = []
					while flags.count < coordinateCount {
						let flag = try bytes.nextUInt8()
						flags.append(flag)
						
						if flag & 8 != 0 {
							let repeatCount = try bytes.nextUInt8()
							flags += [UInt8](repeating: flag, count: Int(repeatCount))
						}
					}
					
					if flags.count != coordinateCount { throw Error.glyphFlagCountMismatch }
					
					var points: [Point] = []
					var prevX: Int16 = 0, prevY: Int16 = 0
					
					for i in 0..<coordinateCount {
						let flag = flags[i]
						let x = try bytes.nextCoordinate(with: flag, previous: prevX, isShortMask: 2, isSameMask: 16)
						
						let point = Point(x: x, y: 0, isOnCurve: (flag & 1) > 0, isContourEnd: endpoints.contains(UInt16(i)))
						
						points.append(point)
						prevX = x
					}
					
					for i in 0..<coordinateCount {
						let flag = flags[i]
						let y = try bytes.nextCoordinate(with: flag, previous: prevY, isShortMask: 4, isSameMask: 32)
						points[i].y = y
						prevY = y
					}
					
					var prev: Point?
					var index = 0
					for point in points {
						if let prev = prev, !prev.isOnCurve, !point.isOnCurve {
							let midX = (prev.x + point.x) / 2, midY = (prev.y + point.y) / 2
							
							points.insert(Point(x: midX, y: midY, isOnCurve: true, isContourEnd: false), at: index)
							index += 1
						}
						prev = point
						index += 1
					}
					
					self.points = points
				} else {
					self.points = []
				}
				
				self.components = nil
			} else if count < 0 {		// compound Glyph
				let flag_argsAreWords = 1
				let flag_argsAreXWValues = 2
				let flag_singleScale = 8
				let flag_moreComing = 32
				let flag_xyScale = 64
				let flagEmbeddedMatrix = 128
				let flag_hasInstructions = 256
				
				var flags = flag_moreComing
				var components: [Component] = []
				
				while flags & flag_moreComing > 0 {
					var component = Component()
					
					flags = Int(try bytes.nextUInt16())
					component.index = Int(try bytes.nextUInt16())
					var arg1 = 0, arg2 = 0
					
					if flags & flag_argsAreWords > 0 {
						arg1 = Int(try bytes.nextInt16())
						arg2 = Int(try bytes.nextInt16())
					} else {
						arg1 = Int(try bytes.nextUInt8())
						arg2 = Int(try bytes.nextUInt8())
					}
					
					if flags & flag_argsAreXWValues > 0 {
						component.ctm.tx = CGFloat(arg1)
						component.ctm.ty = CGFloat(arg2)
					} else {
						component.destinationPointIndex = arg1
						component.sourcePointIndex = arg2
					}
					
					if flags & flag_singleScale > 0 {
						component.ctm.a = CGFloat(try bytes.next2Dot14())
						component.ctm.d = component.ctm.a
					} else if flags & flag_xyScale > 0 {
						component.ctm.a = CGFloat(try bytes.next2Dot14())
						component.ctm.d = CGFloat(try bytes.next2Dot14())
					} else if flags & flagEmbeddedMatrix > 0 {
						component.ctm.a = CGFloat(try bytes.next2Dot14())
						component.ctm.b = CGFloat(try bytes.next2Dot14())
						component.ctm.c = CGFloat(try bytes.next2Dot14())
						component.ctm.d = CGFloat(try bytes.next2Dot14())
					}
					
					components.append(component)
				}
				
				if flags & flag_hasInstructions > 0 {
					let instructionLength = try bytes.nextUInt16()
					self.instructions = try bytes.getNext(n: Int(instructionLength))
				} else {
					self.instructions = nil
				}
				self.components = components
				self.points = nil
			} else {
				self.instructions = nil
				self.points = nil
				self.components = nil
			}
			
		}
	}
	

}
