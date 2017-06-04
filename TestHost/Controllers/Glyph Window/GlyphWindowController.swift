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
	var glyph: TrueTypeFont.Glyph?
	
	static func show(glyph: TrueTypeFont.Glyph) -> GlyphWindowController {
		let controller = GlyphWindowController(windowNibName: "GlyphWindowController")
		controller.glyph = glyph
		
		controller.showWindow(nil)
		return controller
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		self.glyphView.showPoints = true
		self.glyphView.glyph = self.glyph
    }
    
}
