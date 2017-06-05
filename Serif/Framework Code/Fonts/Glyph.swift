//
//  Glyph.swift
//  Serif
//
//  Created by Ben Gottlieb on 6/5/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation
import CrossPlatformKit

public protocol Glyph {
	func draw(in bounds: CGRect, context ctx: CGContext, color: UXColor?, includingPoints: Bool, scaleToFont: Bool)
	
	var index: Int { get }
}
