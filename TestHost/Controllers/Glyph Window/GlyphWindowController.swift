//
//  GlyphWindow.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 6/4/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Cocoa
import Serif

class GlyphWindowController: NSWindowController {
	@IBOutlet var glyphView: GlyphView!
	var glyph: Glyph?
	var font: Font?
	
	static func show(glyph: Glyph, from font: Font) -> GlyphWindowController {
		let controller = GlyphWindowController(windowNibName: "GlyphWindowController")
		controller.glyph = glyph
		controller.font = font
		
		controller.showWindow(nil)
		return controller
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		self.glyphView.scaleToFont = false
		self.glyphView.showPoints = true
		self.glyphView.glyph = self.glyph
    }
    
}
