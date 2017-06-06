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
	public let size: CGFloat
	
	public var ascent: CGFloat { return self.convertToDeviceMetric(from: self.descriptor.metrics.ascent) }
	public var descent: CGFloat { return self.convertToDeviceMetric(from: self.descriptor.metrics.descent) }
	public var lineGap: CGFloat { return self.convertToDeviceMetric(from: self.descriptor.metrics.lineGap) }
	public var lineHeight: CGFloat { return self.ascent + abs(self.descent) + self.lineGap }
	
	public func font(ofSize size: CGFloat) -> Font {
		return Font(descriptor: self.descriptor, size: size)
	}
	
	public init(descriptor: FontDescriptor, size: CGFloat) {
		self.descriptor = descriptor
		self.size = size
	}
	
	func convertToDeviceMetric(from value: Int) -> CGFloat {
		return self.size * CGFloat(value) / 1000
	}
}

