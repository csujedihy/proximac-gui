//
//  ViewController.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/29/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa
import MASPreferences


class MainViewController: NSViewController {

  @IBOutlet weak var listManagementSeg: NSSegmentedControl!
  @IBOutlet weak var mainTableView: NSTableView!
  @IBOutlet weak var masterToggleLabel: NSButton!
  @IBOutlet weak var masterToggleView: OGSwitch!
  @IBOutlet weak var settingsButton: NSButton!
  
  lazy var preferenceWindowController: NSWindowController = {
    return MASPreferencesWindowController(viewControllers: [
      PrefGeneralViewController(),
      PrefNetworkViewController(),
      ], title: "Preference")
  }()
  lazy var settingsMenu = NSMenu()
  var prefForKVO: Preferences?
  var rulesTable = [Rule]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRulesTableView()
    setupSettingsMenu()
    masterToggleView.setOn(isOn: Preferences.sharedInstance.isEnabled ?? false, animated: false)
    masterToggleView.action = #selector(masterToggleOnClick(_:))
    prefForKVO = Preferences.sharedInstance
    prefForKVO?.addObserver(self, forKeyPath: #keyPath(Preferences.rules), options: .new, context: nil)
    
    // Do any additional setup after loading the view.
  }
  
  func setupSettingsMenu() {
    settingsButton.action = #selector(settingsButtonOnClick(_:))
    let settingsItem = NSMenuItem(title: "Preferences", action: #selector(openSettingsOnMenu), keyEquivalent: "c")
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quitAppOnMenu), keyEquivalent: "q")
    settingsMenu.addItem(settingsItem)
    settingsMenu.addItem(quitItem)
  }
  
  func settingsButtonOnClick(_ sender: Any?) {
    if let button = sender as? NSButton {
      let p = NSPoint(x: 0, y: button.frame.height)
      settingsMenu.popUp(positioning: nil, at: p, in: button)
    }
  }
  
  func quitAppOnMenu(_ sender: Any?) {
    Preferences.sharedInstance.sync()
    NSApplication.shared().terminate(self)
    // shut down proxy and so on
  }
  
  func openSettingsOnMenu(_ sender: Any?) {
    preferenceWindowController.showWindow(self)
  }
  
  func setupRulesTableView() {
    mainTableView.delegate = self
    mainTableView.dataSource = self
    loadRulesFromPreferences()
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let _ = object as? Preferences {
      loadRulesFromPreferences()
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  func masterToggleOnClick(_ sender: Any?) {
    print("master toggled")
    if let masterToggleView = sender as? OGSwitch {
      print("enter")
      Preferences.sharedInstance.toggle(masterToggleView.isOn)
    }
  }
  
  func loadRulesFromPreferences() {
    if let rules = Preferences.sharedInstance.rules {
      rulesTable = Array(rules.values)
      mainTableView.reloadData()
    }
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    if let window = self.view.window {
      window.title = "Proximac"
    }
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  @IBAction func listManagementSegOnClick(_ sender: Any) {
    let segControl = sender as! NSSegmentedControl
    let selectedIndex = segControl.selectedSegment
    
    if selectedIndex == 0 {
      let storyboard = NSStoryboard(name: "Main", bundle: nil)
      if let rulesMakerVC = storyboard.instantiateController(withIdentifier: "RulesMakerVC") as? NSViewController {
        self.presentViewControllerAsSheet(rulesMakerVC)
      }
    } else if selectedIndex == 1 {
      let row = mainTableView.selectedRow
      rulesTable[row].destroy()

    }
  }
  
  func ruleToggleOnClick(_ sender: Any?) {
    if let switchView = sender as? OGSwitch {
      let rule = rulesTable[switchView.tableTag]
      rule.toggleRule(switchView.isOn)
    }
  }
  
  deinit {
    prefForKVO?.removeObserver(self, forKeyPath: #keyPath(Preferences.rules))
  }
}


extension MainViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return rulesTable.count
  }
}

extension MainViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let rule = rulesTable[row]
    if let cell = tableView.make(withIdentifier: "RuleCard", owner: nil) as? RuleCardCellView {
      cell.ruleNameLabel.stringValue = "Rule: " + (rule.ruleName ?? "Unknown")
      cell.appNameLabel.stringValue = "App: " + (rule.appName ?? "Unknown")
      cell.appPathLabel.stringValue = "Path: " + (rule.appPath ?? "Unkown")
      cell.switchView.action = #selector(ruleToggleOnClick(_:))
      cell.switchView.tableTag = row
      cell.switchView.setOn(isOn: rule.isEnabled ?? false, animated: false)

      if let appPath = rule.appPath {
        cell.appIconImageView.image = NSWorkspace.shared().icon(forFile: appPath)
      }
      return cell
    }
    return nil
  }
  
}


