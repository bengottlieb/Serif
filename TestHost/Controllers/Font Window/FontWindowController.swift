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
	
	var url: URL?
	var font: TrueTypeFont?
	var glyphWindows: [GlyphWindowController] = []
	
	static func restoreOpenFonts() {
		guard let fonts = UserDefaults.standard.value(forKey: "openFonts") as? [String] else { return }
		
		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: .NSApplicationWillTerminate, object: nil)
		
		fonts.forEach {
			if let url = URL(string: $0) {
				self.showFont(at: url)
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
		if let font = TrueTypeFont(url: url) {
			self.show(font: font)
		}
	}
	
	static func show(font: Font) {
		if let window = FontWindowController(font: font) {
			self.windows.append(window)
			window.showWindow(nil)
			
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
}
