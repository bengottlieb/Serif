//
//  TrueTypeFont+ByteArray.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/29/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

struct ByteArrayParser {
	enum IndexedByteError: Error { case outOfBounds }
	let bytes: [UInt8]
	var index = 0
	var start = 0
	let count: Int
	
	init(bytes: [UInt8], index: Int = 0, length: Int? = nil) {
		self.bytes = bytes
		self.start = index
		self.count = length ?? (bytes.count - index)
	}
	
	subscript(_ range: Range<Int>) -> ByteArrayParser {
		return ByteArrayParser(bytes: self.bytes, index: self.start + range.lowerBound, length: range.upperBound - range.lowerBound)
	}
	
	subscript(unshifted range: Range<Int>) -> ByteArrayParser {
		return ByteArrayParser(bytes: self.bytes, index: range.lowerBound, length: range.upperBound - range.lowerBound)
	}
	
	mutating func skip(_ count: Int) { self.index += count }
	
	mutating func jump(to: Int) { self.index = to }
	
	var currentIndex: Int { return self.start + self.index }
	mutating func getNext(n: Int) throws -> [UInt8] {
		let result = try self.getRange(Int(self.index)..<Int(self.index + n))
		self.index += n
		return result
	}
	
	func getRange(_ range: Range<Int>) throws -> [UInt8] {
		if range.upperBound > self.count || range.lowerBound > self.count { throw IndexedByteError.outOfBounds }
		return Array(self.bytes[Int(range.lowerBound)..<Int(range.upperBound)])
	}
	
	mutating func nextInt8() throws -> Int8 {
		if self.index >= self.count { throw IndexedByteError.outOfBounds }
		let result = Int8(bytes[self.currentIndex])
		self.index += 1
		return result
	}
	
	mutating func nextUInt8() throws -> UInt8 {
		if self.index > (self.count - 1) { throw IndexedByteError.outOfBounds }
		let result = bytes[self.currentIndex]
		self.index += 1
		return result
	}
	
	mutating func nextInt16() throws -> Int16 {
		if self.index > (self.count - 2) { throw IndexedByteError.outOfBounds }
		let result = bytes.int16(at: self.currentIndex)
		self.index += 2
		return result
	}
	
	mutating func nextUInt16() throws -> UInt16 {
		if self.index > (self.count - 2) { throw IndexedByteError.outOfBounds }
		let result = bytes.uint16(at: self.currentIndex)
		self.index += 2
		return result
	}
	
	mutating func nextInt32() throws -> Int32 {
		if self.index > (self.count - 4) { throw IndexedByteError.outOfBounds }
		let result = bytes.int32(at: self.currentIndex)
		self.index += 4
		return result
	}
	
	mutating func nextUInt32() throws -> UInt32 {
		if self.index > (self.count - 4) { throw IndexedByteError.outOfBounds }
		let result = bytes.uint32(at: self.currentIndex)
		self.index += 4
		return result
	}
	
	mutating func nextInt64() throws -> Int64 {
		if self.index > (self.count - 8) { throw IndexedByteError.outOfBounds }
		let l1 = bytes.uint32(at: self.currentIndex)
		let l2 = bytes.uint32(at: self.currentIndex + 4)
		self.index += 8
		return Int64(l1) << 32 | Int64(l2)
	}
	
	mutating func nextFixed() throws -> Float {
		if self.index > (self.count - 4) { throw IndexedByteError.outOfBounds }
		let mag = Float(try nextInt32())
		
		return mag / Float(1 << 16)
	}
	
	mutating func next2Dot14() throws -> Float {
		if self.index > (self.count - 2) { throw IndexedByteError.outOfBounds }
		let mag = Float(try nextInt16())
		
		return mag / Float(1 << 14)
	}
	
	func uint32(offsetBy offset: Int) throws -> UInt32 {
		if self.index > (self.count - 4) { throw IndexedByteError.outOfBounds }
		let result = bytes.uint32(at: self.currentIndex + offset)
		return result
	}
}

extension Array where Element == UInt8 {
	func uint32(at offset: Int) -> UInt32 {
		return UInt32(self[offset]) << 24 | UInt32(self[offset + 1]) << 16 | UInt32(self[offset + 2]) << 8 | UInt32(self[offset + 3])
	}
	
	func int32(at offset: Int) -> Int32 {
		return Int32(self[offset]) << 24 | Int32(self[offset + 1]) << 16 | Int32(self[offset + 2]) << 8 | Int32(self[offset + 3])
	}
	
	func uint16(at offset: Int) -> UInt16 {
		return UInt16(self[offset]) << 8 | UInt16(self[offset + 1])
	}
	
	func int16(at offset: Int) -> Int16 {
		return Int16(self[offset]) << 8 | Int16(self[offset + 1])
	}
}
