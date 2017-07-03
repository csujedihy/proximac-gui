//
//  PrefNetworkViewController.swift
//  proximac-gui
//
//  Created by Yi Huang on 7/2/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa
import MASPreferences

class PrefNetworkViewController: NSViewController, MASPreferencesViewController {
  @IBOutlet weak var changeSettingsButton: NSButton!
  
  override var nibName: String {
    return "PrefNetworkViewController"
  }
  
  override var identifier: String? {
    get {
      return "PrefNetwork"
    }
    set {
      super.identifier = newValue
    }
  }
  
  var toolbarItemImage: NSImage {
    get {
      return NSImage(named: "NSNetwork")!
    }
  }
  
  var toolbarItemLabel: String {
    get {
      view.layoutSubtreeIfNeeded()
      return "Network"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    changeSettingsButton.target = self
    changeSettingsButton.action = #selector(changeSettingsButtonOnClick(_:))
  }
  
  func changeSettingsButtonOnClick(_ sender: Any?) {
    if let vc = PrefSubSOCKS5ViewController(nibName: "PrefSubSOCKS5ViewController", bundle: nil) {
      self.presentViewControllerAsSheet(vc)
    }
  }
  
}
