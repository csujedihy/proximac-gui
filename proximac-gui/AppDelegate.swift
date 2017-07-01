//
//  AppDelegate.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/29/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



  func applicationDidFinishLaunching(_ aNotification: Notification) {
    for app in NSWorkspace.shared().runningApplications {
      print(app.bundleURL)
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}

