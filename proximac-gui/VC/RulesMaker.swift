//
//  RulesMaker.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/30/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa

class RulesMaker: NSViewController {

  
  @IBOutlet weak var ruleNameTextField: NSTextField!
  
  @IBOutlet weak var appIconImageView: ClickableImageView!
  
  @IBOutlet weak var nameLabel: NSTextField!
  @IBOutlet weak var pathLabel: NSTextField!
  @IBOutlet weak var okButton: NSButton!
  @IBOutlet weak var cancelButton: NSButton!
  
  var selectedAppName: String?
  var selectedAppPath: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    appIconImageView.onClick = appIconOnClick
  }
  
  
  @IBAction func okOnClick(_ sender: Any) {
    guard let appName = selectedAppName, let appPath = selectedAppPath else {
      Utility.showAlert("You need to specify an application")
      return
    }
    
    let ruleName = ruleNameTextField.stringValue
    
    if ruleName.characters.count == 0 {
      Utility.showAlert("You need to name this rule")
      return
    }
    
    if Preferences.checkExist(ruleName: ruleName) == true {
      Utility.showAlert("You already created a rule called " + ruleName)
      return
    }
    
    let rule = Rule(ruleName: ruleName, appName: appName, appPath: appPath, isEnabled: false)
    Preferences.sharedInstance.addRule(rule: rule)
    self.dismissViewController(self)
  }
  
  @IBAction func cancelOnClick(_ sender: Any) {
    self.dismissViewController(self)
  }
  
  func appIconOnClick(imageView: ClickableImageView, sender: Any) {
    print("appIconOnClick")
    let applicationsFolderPath = FileManager.default.urls(for: .adminApplicationDirectory, in:.userDomainMask).first
    Utility.openFilePanel("Choose Application", isDir: true, baseDir: applicationsFolderPath) { (appPath: URL) in
      let selectedPath = appPath
      let icon = NSWorkspace.shared().icon(forFile: selectedPath.path)
      imageView.image = icon
      self.nameLabel.stringValue = "Name: " + selectedPath.lastPathComponent
      self.pathLabel.stringValue = "Path: " + selectedPath.path
      self.selectedAppName = selectedPath.lastPathComponent
      self.selectedAppPath = selectedPath.path
    }
  }
  
  
}
