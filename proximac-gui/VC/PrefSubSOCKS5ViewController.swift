//
//  PrefSubSOCKS5ViewController.swift
//  proximac-gui
//
//  Created by Yi Huang on 7/2/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa

class PrefSubSOCKS5ViewController: NSViewController {

  @IBOutlet weak var serverIPTextField: NSTextField!
  @IBOutlet weak var serverPortTextField: NSTextField!
  @IBOutlet weak var cancelButton: NSButton!
  @IBOutlet weak var okButton: NSButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cancelButton.action = #selector(cancelButtonOnClick)
    okButton.action = #selector(okButtonOnClick)
    
    serverIPTextField.stringValue = Preferences.sharedInstance.socks5ServerIP ?? ""
    serverPortTextField.stringValue = Preferences.sharedInstance.socks5ServerPort ?? ""
  }
  
  func cancelButtonOnClick(_ sender: Any?) {
    self.dismissViewController(self)
  }
  
  func okButtonOnClick(_ sender: Any?) {
    if Utility.validateIpAddress(serverIPTextField.stringValue) == false {
      Utility.showAlert("Please input correct IP address")
      return
    }
    if Utility.validatePortNumberString(serverPortTextField.stringValue) == false {
      Utility.showAlert("Please input correct Port Number")
      return
    }
    Preferences.sharedInstance.socks5ServerIP = serverIPTextField.stringValue
    Preferences.sharedInstance.socks5ServerPort = serverPortTextField.stringValue
    Preferences.sharedInstance.sync()
    self.dismissViewController(self)
    
  }
}
