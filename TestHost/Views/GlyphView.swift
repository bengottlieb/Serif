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
	var glyph: Glyph? { didSet { self.setNeedsDisplay(self.bounds) }}
	var font: Font? { didSet { self.setNeedsDisplay(self.bounds) }}
	
	override func draw(_ dirtyRect: NSRect) {		
		guard let ctx = NSGraphicsContext.current()?.cgContext, let glyph = self.glyph, let font = self.font else { return }
		
		glyph.draw(in: self.bounds, context: ctx, from: font, color: nil, includingPoints: self.showPoints, scaleToFont: self.scaleToFont)
		
		var indexText = "\(glyph.index)"
		if let cid = glyph.descriptor.characterMap.map(gid: glyph.index) { indexText += "/\(cid)" }
		
		let attr = NSAttributedString(string: indexText, attributes: [NSFontAttributeName: NSFont.systemFont(ofSize: 10)])
		attr.draw(at: CGPoint(x: self.bounds.width - (attr.size().width + 1), y: 0))
		
		NSColor(white: 0.9, alpha: 1.0).set()
		NSFrameRect(self.bounds)
	}
}
