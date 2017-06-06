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
	@IBOutlet var fontSizeSlider: NSSlider!
	@IBOutlet var fontSizeLabel: NSTextField!
	
	var pointSize: CGFloat = 14 { didSet {
		self.font = self.font?.font(ofSize: self.pointSize)
		self.updateLayoutSizes()
	}}
	var descriptors: [FontDescriptor] = []
	var url: URL?
	var font: Font? { didSet {
		self.glyphCollectionView?.reloadData()
	}}
	var glyphWindows: [GlyphWindowController] = []
	
	static func restoreOpenFonts() {
		guard let fonts = UserDefaults.standard.value(forKey: "openFonts") as? [String] else { return }
		
		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: .NSApplicationWillTerminate, object: nil)
		
		fonts.forEach {
			print("Attempting to re-open: \($0)")

			if let url = URL(string: $0), let collection = FontCollection.collection(at: url) {
				self.show(collection: collection)
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
			self.show(collection: collection)
		} else if url.pathExtension == "ttf", let descriptor = TrueTypeDescriptor(url: url) {
			self.show(descriptor: descriptor)
		}
	}
	
	static func show(collection: FontCollection) {
		if let descriptor = collection.descriptors.first as? TrueTypeDescriptor, let window = FontWindowController(descriptor: descriptor) {
			window.descriptors = collection.descriptors
			window.url = collection.url
			self.windows.append(window)
			window.showWindow(nil)
			
			self.saveOpenFonts()
		}
	}

	static func show(descriptor: FontDescriptor) {
		if let window = FontWindowController(descriptor: descriptor) {
			self.windows.append(window)
			window.showWindow(nil)
			window.url = descriptor.url

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
	
	convenience init?(descriptor: FontDescriptor) {
		self.init(windowNibName: "FontWindowController")
		if !self.load(descriptor: descriptor) { return nil }
	}
	
	override func loadWindow() {
		super.loadWindow()
		self.window?.title = self.windowTitle
		
		self.reloadFontPicker()
	}
	
	func reloadFontPicker() {
		self.fontMenu.removeAllItems()
		
		for font in self.descriptors {
			self.fontMenu.addItem(withTitle: font.title ?? "Untitled Font")
		}
	}
	
	func load(descriptor: FontDescriptor) -> Bool {
		self.font = Font(descriptor: descriptor, size: 12)
		self.updateLayoutSizes()
		return self.font != nil
	}
	
	func loadFont(at url: URL?) -> Bool {
		guard let url = url else { return false }
		self.url = url
		if let desc = TrueTypeDescriptor(url: url) {
			return self.load(descriptor: desc)
		}
		return false
	}
	
	var windowTitle: String {
		let count = self.font?.descriptor.numberOfGlyphs ?? 0
		return (self.font?.descriptor.title ?? "Untitled Font") + ", \(count) glyphs"
	}
	
	var layout: NSCollectionViewFlowLayout!
    override func windowDidLoad() {
        super.windowDidLoad()
		
		self.layout = NSCollectionViewFlowLayout()
		self.glyphCollectionView.collectionViewLayout = self.layout
		
		self.glyphCollectionView.register(NSNib(nibNamed: "GlyphCollectionViewItem", bundle: Bundle.main), forItemWithIdentifier: GlyphCollectionViewItem.identifier)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
	
	@IBAction func didSelectFont(_ sender: Any?) {
		let index = self.fontMenu.indexOfSelectedItem
		if index < self.descriptors.count {
			self.font = Font(descriptor: self.descriptors[index], size: self.pointSize)
		}
	}
	
	@IBAction func fontSizeChanged(_ sender: Any?) {
		self.fontSizeLabel.stringValue = "\(Int(self.fontSizeSlider.doubleValue)) pt."
		self.pointSize = CGFloat(self.fontSizeSlider.doubleValue)
	}
}
