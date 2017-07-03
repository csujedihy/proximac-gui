//
//  PrefGeneralViewController.swift
//  proximac-gui
//
//  Created by Yi Huang on 7/2/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa
import MASPreferences

class PrefGeneralViewController: NSViewController, MASPreferencesViewController {
  override var nibName: String {
    return "PrefGeneralViewController"
  }
  
  override var identifier: String? {
    get {
      return "PrefGeneral"
    }
    set {
      super.identifier = newValue
    }
  }
  
  var toolbarItemImage: NSImage {
    get {
      return NSImage(named: "NSPreferencesGeneral")!
    }
  }
  
  var toolbarItemLabel: String {
    get {
      view.layoutSubtreeIfNeeded()
      return "General"
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
        // Do view setup here.
  }
    
}
