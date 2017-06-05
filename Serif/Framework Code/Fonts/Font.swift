//
//  Font.swift
//  Serif
//
//  Created by Ben Gottlieb on 6/5/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

public class Font {
	public let descriptor: FontDescriptor
	public let size: Int
	
	public init(descriptor: FontDescriptor, size: Int) {
		self.descriptor = descriptor
		self.size = size
	}
}
