//
//  FontWindowController.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/30/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Cocoa
import Serif

class FontWindowController: NSWindowController {
	@IBOutlet var glyphCollectionView: NSCollectionView!
	@IBOutlet var fontMenu: NSPopUpButton!
	
	var fonts: [TrueTypeFont] = []
	var url: URL?
	var font: TrueTypeFont? { didSet {
		self.glyphCollectionView?.reloadData()
	}}
	var glyphWindows: [GlyphWindowController] = []
	
	static func restoreOpenFonts() {
		guard let fonts = UserDefaults.standard.value(forKey: "openFonts") as? [String] else { return }
		
		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: .NSApplicationWillTerminate, object: nil)
		
		fonts.forEach {
			if let url = URL(string: $0), let collection = FontCollection.collection(at: url) {
				self.show(fontCollection: collection)
			}
		}
	}
	
	static var terminating = false
	static func applicationWillTerminate() {
		self.terminating = true
	}
	
	static func saveOpenFonts() {
		let fonts = self.windows.flatMap { $0.url?.absoluteString }
		UserDefaults.standard.set(fonts, forKey: "openFonts")
	}
	
	static var windows: [FontWindowController] = []
	static func showFont(at url: URL) {
		if url.pathExtension == "ttc", let collection = FontCollection(url: url) {
			self.show(fontCollection: collection)
		} else if url.pathExtension == "ttf", let font = TrueTypeFont(url: url) {
			self.show(font: font)
		}
	}
	
	static func show(fontCollection: FontCollection) {
		if let font = fontCollection.fonts.first as? TrueTypeFont, let window = FontWindowController(font: font) {
			window.fonts = fontCollection.fonts as? [TrueTypeFont] ?? []
			window.url = fontCollection.url
			self.windows.append(window)
			window.showWindow(nil)
			
			self.saveOpenFonts()
		}
	}

	static func show(font: Font) {
		if let window = FontWindowController(font: font) {
			self.windows.append(window)
			window.showWindow(nil)
			window.url = font.url

			self.saveOpenFonts()
		}
	}
	
	func windowWillClose(_ notification: Notification) {
		if !FontWindowController.terminating, let index = FontWindowController.windows.index(of: self) {
			FontWindowController.windows.remove(at: index)
			FontWindowController.saveOpenFonts()
			
			self.glyphWindows.forEach {
				$0.close()
			}
		}
	}
	
	convenience init?(url: URL) {
		self.init(windowNibName: "FontWindowController")
		if !self.loadFont(at: url) { return nil }
	}
	
	convenience init?(font: Font) {
		self.init(windowNibName: "FontWindowController")
		if !self.load(font: font) { return nil }
	}
	
	override func loadWindow() {
		super.loadWindow()
		self.window?.title = self.windowTitle
		
		self.reloadFontPicker()
	}
	
	func reloadFontPicker() {
		self.fontMenu.removeAllItems()
		
		for font in self.fonts {
			self.fontMenu.addItem(withTitle: font.title ?? "Untitled Font")
		}
	}
	
	func load(font: Font) -> Bool {
		guard let fnt = font as? TrueTypeFont else { return false }
		self.font = fnt
		return self.font != nil
	}
	
	func loadFont(at url: URL?) -> Bool {
		guard let url = url else { return false }
		self.url = url
		if let font = TrueTypeFont(url: url) {
			return self.load(font: font)
		}
		return false
	}
	
	var windowTitle: String {
		let count = self.font?.glyphs?.count ?? 0
		return (self.font?.title ?? "Untitled Font") + ", \(count) glyphs"
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		self.glyphCollectionView.register(NSNib(nibNamed: "GlyphCollectionViewItem", bundle: Bundle.main), forItemWithIdentifier: GlyphCollectionViewItem.identifier)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
	
	func updateGlyphsCollection() {
		
	}
	
	@IBAction func didSelectFont(_ sender: Any?) {
		let index = self.fontMenu.indexOfSelectedItem
		if index < self.fonts.count {
			self.font = self.fonts[index]
		}
	}
}
