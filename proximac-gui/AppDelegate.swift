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
  let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
  let popover = NSPopover()
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if let button = statusItem.button {
      button.image = NSImage(named: "StatusBarButtonImage")
      button.action = #selector(togglePopover)
    }
    
    let storyBoard = NSStoryboard(name: "Main", bundle: nil)
    if let vc = storyBoard.instantiateController(withIdentifier: "MainVC") as? MainViewController {
      popover.contentViewController = vc
    }
  }
  
  
  func showPopover(_ sender: AnyObject?) {
    if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
  }
  
  func closePopover(_ sender: AnyObject?) {
    popover.performClose(sender)
  }
  
  func togglePopover(sender: AnyObject?) {
    if popover.isShown {
      closePopover(sender)
    } else {
      showPopover(sender)
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}

