//
//  DescriptorProtocols.swift
//  Serif
//
//  Created by Ben Gottlieb on 6/6/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation


public protocol CharacterMap {
	func map(cid: Int) -> Int?
	func map(gid: Int) -> Int?
}

public protocol DescriptorMetrics {
	var ascent: Int { get }
	var descent: Int { get }
	var lineGap: Int { get }
}
