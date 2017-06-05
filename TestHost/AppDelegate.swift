//
//  AppDelegate.swift
//  FontExplorer
//
//  Created by Ben Gottlieb on 5/23/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Cocoa
import Serif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(_ aNotification: Notification) {
	//	if let url = Bundle.main.url(forResource: "TTF9t00", withExtension: "ttf", subdirectory: "Sample Fonts") {
		//	FontWindowController.showFont(at: url)
	//	}
		
	//	FontWindowController.showFont(at: URL(fileURLWithPath: "/Library/Fonts/Arial Bold.ttf"))
		FontWindowController.restoreOpenFonts()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


	func application(_ sender: NSApplication, openFiles filenames: [String]) {
		for filename in filenames {
			print("Attempting to open: \(filename)")

			let url = URL(fileURLWithPath: filename)
			FontWindowController.showFont(at: url)
		}
	}
}

