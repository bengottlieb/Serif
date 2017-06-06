//
//  GlyphCollectionViewItem.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/30/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Cocoa
import Serif

class GlyphCollectionViewItem: NSCollectionViewItem {
	static let identifier = "GlyphCollectionViewItem"
	
	var glyph: Glyph? { didSet { self.glyphView?.glyph = self.glyph }}

	@IBOutlet var glyphView: GlyphView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.glyphView?.glyph = self.glyph
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.glyphView?.glyph = self.glyph
	}
    
}
