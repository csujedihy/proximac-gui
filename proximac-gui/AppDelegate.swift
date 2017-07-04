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
  var eventMonitor: EventMonitor?
  var backendServer: SocketsServer?
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
    
    eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
      if self.popover.isShown {
        self.closePopover(event)
      }
    }
    eventMonitor?.start()
    backendServer = SocketsServer()
    backendServer?.listenForTrafficFromKernel()
  }
  
  
  func showPopover(_ sender: AnyObject?) {
    if let button = statusItem.button {
      eventMonitor?.start()
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
  }
  
  func closePopover(_ sender: AnyObject?) {
    popover.performClose(sender)
    eventMonitor?.stop()
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

