//
//  FontDescriptor.swift
//  Serif
//
//  Created by Ben Gottlieb on 6/4/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

public class FontDescriptor {
	public var title: String? { return "" }
	public let url: URL?
	public var numberOfGlyphs: Int { return 0 }
	let data: Data!
	
	public var glyphs: GlyphCollection!
	public var characterMap: CharacterMap!
	public var metrics: DescriptorMetrics!
	
	public var bbox: CGRect { return .zero }
	
	public init(data: Data!, url: URL? = nil) {
		self.data = data
		self.url = url
	}
	
	public static func descriptor(at url: URL) -> FontDescriptor? {
		if url.pathExtension == "ttf" { return TrueTypeDescriptor(url: url) }
		return nil
	}
}
