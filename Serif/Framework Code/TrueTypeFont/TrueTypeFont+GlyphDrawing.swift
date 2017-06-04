//
//  TrueTypeFont+GlyphDrawing.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 6/4/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation
import CrossPlatformKit

extension TrueTypeFont.Glyph {
	public func draw(in bounds: CGRect, context ctx: CGContext, color: UXColor? = nil, includingPoints: Bool = false) {
		let fontWidth = self.font.size.width - self.font.origin.x
		let fontHeight = self.font.size.height - self.font.origin.y
		let scale = min(bounds.width / fontWidth, bounds.height / fontHeight)
		
		ctx.saveGState()
		if let color = color { ctx.setFillColor(color.cgColor) }
		
		if let components = self.components {
			for component in components {
				ctx.saveGState()
				var transform = CGAffineTransform(translationX: -self.font.origin.x + component.ctm.tx, y: -self.font.origin.y + component.ctm.ty)
				transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
				ctx.concatenate(transform)
				
				let glyph = self.font.glyphs[component.index]
				glyph?.draw(in: ctx, includingPoints: includingPoints)
				
				ctx.restoreGState()
			}
		} else {
			var transform = CGAffineTransform(translationX: -self.font.origin.x, y: -self.font.origin.y)
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
			let ptSize: CGFloat = 40
			for pt in points {
				let rect = CGRect(x: CGFloat(pt.x) - ptSize / 2, y: CGFloat(pt.y) - ptSize / 2, width: ptSize, height: ptSize)
				
				if pt.isOnCurve {
					UXColor.green.set()
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
