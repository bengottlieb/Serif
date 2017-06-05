//
//  TrueTypeFont+GlyphDrawing.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 6/4/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation
import CrossPlatformKit

// more info on drawing glyphs: https://developer.apple.com/fonts/TrueType-Reference-Manual/RM01/Chap1.html#necessary
// http://chanae.walon.org/pub/ttf/ttf_glyphs.htm


extension TrueTypeFont.TrueTypeGlyph {
	public func draw(in bounds: CGRect, context ctx: CGContext, color: UXColor? = nil, includingPoints: Bool = false, scaleToFont: Bool = true) {
		let frame = includingPoints ? bounds.insetBy(dx: 20, dy: 20) : bounds
		let bbox = scaleToFont ? self.font.bbox : self.bbox
		let fontWidth = bbox.width - bbox.origin.x
		let fontHeight = bbox.height - bbox.origin.y
		let scale = min(frame.width / fontWidth, frame.height / fontHeight)
		
		ctx.saveGState()
		if let color = color { ctx.setFillColor(color.cgColor) }
		
		if let components = self.components {
			for component in components {
				ctx.saveGState()
				var transform = CGAffineTransform(translationX: -bbox.origin.x + component.ctm.tx + frame.origin.x, y: -bbox.origin.y + component.ctm.ty + frame.origin.y)
				transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
				ctx.concatenate(transform)
				
				let glyph = self.font.glyphs[component.index]
				glyph?.draw(in: ctx, includingPoints: includingPoints)
				
				ctx.restoreGState()
			}
		} else {
			var transform = CGAffineTransform(translationX: -bbox.origin.x + frame.origin.x, y: -bbox.origin.y + frame.origin.y)
			transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
			ctx.concatenate(transform)
			self.draw(in: ctx, includingPoints: includingPoints)
		}
		ctx.restoreGState()
	}
	
	func draw(in ctx: CGContext, includingPoints: Bool = false) {
		for i in 0..<self.numberOfContours {
			guard let path = self.nthContour(i) else { continue }
			
			ctx.addPath(path)
		}
		ctx.fillPath(using: .winding)
		
		if includingPoints, let points = self.points {
			let ptSize: CGFloat = 30
			for pt in points {
				let rect = CGRect(x: CGFloat(pt.x) - ptSize / 2, y: CGFloat(pt.y) - ptSize / 2, width: ptSize, height: ptSize)
				
				UXColor.white.set()
				ctx.setLineWidth(10)
				ctx.strokeEllipse(in: rect)
				
				ctx.setLineWidth(5)
				if pt.isOnCurve {
					UXColor.blue.set()
				} else {
					UXColor.red.set()
				}
				ctx.strokeEllipse(in: rect)
			}
		}
	}

	public func nthContour(_ n: Int) -> CGMutablePath? {
		guard n < self.numberOfContours, let points = self.points, let first = self.startingPoint(forContour: n) else { return nil }
		
		let path = CGMutablePath()
		var controlPoints: [CGPoint] = []
		
		for i in first..<points.count {
			let point = points[i]
			if i == first {
				path.move(to: point.point)
			} else if point.isOnCurve {
				if controlPoints.count == 0 {
					path.addLine(to: point.point)
				} else if controlPoints.count == 1 {
					path.addQuadCurve(to: point.point, control: controlPoints[0])
				}
				controlPoints = []
			} else {
				controlPoints.append(point.point)
			}
			
			if point.isContourEnd { break }
		}
		
		//if we ended on an control point, finish off the path to the first point
		if let cp = controlPoints.first { path.addQuadCurve(to: points[first].point, control: cp) }
		
		
		return path
	}
	
	func startingPoint(forContour n: Int) -> Int? {
		guard let points = self.points else { return nil }
		
		var remaining = n
		
		for i in 0..<points.count {
			if i == 0 || points[i - 1].isContourEnd {
				if remaining == 0 { return i }
				remaining -= 1
			}
		}
		
		return nil
	}
	
}
