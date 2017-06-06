//
//  FontWindowController+CollectionView.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/30/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Cocoa

extension FontWindowController: NSCollectionViewDelegate {
	public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		guard let path = indexPaths.first,
			let cell = collectionView.item(at: path) as? GlyphCollectionViewItem, let glyph = cell.glyph, let font = self.font else { return }
		
		self.glyphWindows.append(GlyphWindowController.show(glyph: glyph, from: font))
	//	cell.view.setNeedsDisplay(cell.view.bounds)
		collectionView.deselectItems(at: indexPaths)
	}
}

extension FontWindowController: NSCollectionViewDataSource {
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.font?.descriptor.numberOfGlyphs ?? 0
	}
	
	public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		
		let item = collectionView.makeItem(withIdentifier: GlyphCollectionViewItem.identifier, for: indexPath)
		
		if let glyphItem = item as? GlyphCollectionViewItem {
			glyphItem.glyph = self.font?.descriptor.glyphs[indexPath.item]
			glyphItem.font = self.font
		}
		return item
	}
}
