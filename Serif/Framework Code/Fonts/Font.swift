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
	
	public var ascent: CGFloat { return self.convertToDeviceMetric(from: self.descriptor.metrics.ascent) }
	public var descent: CGFloat { return self.convertToDeviceMetric(from: self.descriptor.metrics.descent) }
	public var lineGap: CGFloat { return self.convertToDeviceMetric(from: self.descriptor.metrics.lineGap) }
	
	public init(descriptor: FontDescriptor, size: Int) {
		self.descriptor = descriptor
		self.size = size
	}
	
	func convertToDeviceMetric(from value: Int) -> CGFloat {
		return CGFloat(value * 72) / 1000
	}
}

