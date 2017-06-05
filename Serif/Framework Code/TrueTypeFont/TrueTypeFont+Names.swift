//
//  TrueTypeFont+Names.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/26/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension TrueTypeFont {
	public struct Names {
		public enum Identifier: Int { case copyright, family, subfamily, subfamilyID, fullName, nameTableVersion, postscriptName, trademarkNotice, manufacturer, designer, description, vendorURLL, designerURL, license, unused_1, preferredFamily, preferredSubfamily, compatible, sampleText }
		
		struct Name {
			let identifier: Identifier?
			let name: String
		}
		
		public func name(with id: Identifier) -> String? {
			for name in self.names {
				if name.identifier == id { return name.name }
			}
			return nil
		}
		
		let names: [Name]
		init(namesTable: Table) throws {
			var bytes = namesTable.parser
			
			bytes.skip(2)			//skip the version
			let nameCount = try bytes.nextUInt16()
			let firstNameOffset = try bytes.nextUInt16()	//bytes.skip(2)			//string offset
			var names: [Name] = []
			
			for _ in 0..<nameCount {
				bytes.skip(2)		// platformID
				bytes.skip(2)		// platform-specific ID
				bytes.skip(2)		// language
				let identifier = try bytes.nextUInt16()
				let length = try bytes.nextUInt16()
				let offset = try bytes.nextUInt16() + firstNameOffset
				let content = try bytes.getRange(Int(offset)..<Int(offset + length))
				
				if let name = String(bytes: content, encoding: content[0] < 5 ? .utf16 : .utf8) {
					names.append(Name(identifier: Identifier(rawValue: Int(identifier)), name: name))
				}
			}
			
			self.names = names
		}
	}
}
