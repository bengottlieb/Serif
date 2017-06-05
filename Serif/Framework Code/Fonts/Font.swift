//
//  Font.swift
//  Serif
//
//  Created by Ben Gottlieb on 6/4/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

public class Font {
	public var title: String? { return "" }
	public let url: URL?
	let data: Data!

	public init(data: Data!, url: URL? = nil) {
		self.data = data
		self.url = url
	}
	
	
	public static func font(at url: URL) -> Font? {
		if url.pathExtension == "ttf" { return TrueTypeFont(url: url) }
		return nil
	}
}
