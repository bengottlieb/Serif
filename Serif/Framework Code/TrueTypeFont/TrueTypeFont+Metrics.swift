//
//  TrueTypeDescriptor+Metrics.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/26/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension TrueTypeDescriptor {
	public struct Metrics {
		let version: CGFloat
		let ascent: Int16
		let descent: Int16
		let lineGap: Int16
		let advancedWidthMax: UInt16
		let minLeftsideBearing: Int16
		let minRightSideBearing: Int16
		let xMaxExtent: Int16
		let caretSlopeRise: Int16
		let caretSlopeRun: Int16
		let caretOffset: Int16
		let metricDataFormat: Int16
		let widthsCount: UInt16
		let metrics: [HorizontalMetric]
		
		init(headerTable: Table, metricsTable: Table?) throws {
			var bytes = headerTable.parser
			
			self.version = CGFloat(try bytes.nextFixed())
			self.ascent = try bytes.nextInt16()
			self.descent = try bytes.nextInt16()
			self.lineGap = try bytes.nextInt16()
			self.advancedWidthMax = try bytes.nextUInt16()
			self.minLeftsideBearing = try bytes.nextInt16()
			self.minRightSideBearing = try bytes.nextInt16()
			self.xMaxExtent = try bytes.nextInt16()
			self.caretSlopeRise = try bytes.nextInt16()
			self.caretSlopeRun = try bytes.nextInt16()
			self.caretOffset = try bytes.nextInt16()
			
			bytes.skip(8)
			self.metricDataFormat = try bytes.nextInt16()
			self.widthsCount = try bytes.nextUInt16()
			
			var metrics: [HorizontalMetric] = []
			if var mBytes = metricsTable?.parser {
				for _ in 0..<self.widthsCount {
					let metric = HorizontalMetric(advanceWidth: try mBytes.nextUInt16(), leftSideBearing: try mBytes.nextInt16())
					metrics.append(metric)
				}
			}
			self.metrics = metrics
		}
		
		struct HorizontalMetric {
			let advanceWidth: UInt16
			let leftSideBearing: Int16
		}
		
		
	}
}
