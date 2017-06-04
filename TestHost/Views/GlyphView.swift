//
//  GlyphView.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/30/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Cocoa
import Serif

class GlyphView: NSView {
	var scaleToFont = true
	var showPoints = false
	var glyph: TrueTypeFont.Glyph? { didSet {
		self.setNeedsDisplay(self.bounds)
	}}
	
	override func draw(_ dirtyRect: NSRect) {		
		guard let ctx = NSGraphicsContext.current()?.cgContext, let glyph = self.glyph else { return }
		
		glyph.draw(in: self.bounds, context: ctx, includingPoints: self.showPoints, scaleToFont: self.scaleToFont)
		
		let attr = NSAttributedString(string: "\(glyph.index)", attributes: [NSFontAttributeName: NSFont.systemFont(ofSize: 10)])
		attr.draw(at: CGPoint(x: self.bounds.width - (attr.size().width + 1), y: 0))
		
		NSColor(white: 0.9, alpha: 1.0).set()
		NSFrameRect(self.bounds)
	}
}
