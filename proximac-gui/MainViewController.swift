//
//  ViewController.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/29/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

  @IBOutlet weak var listManagementSeg: NSSegmentedControl!
  @IBOutlet weak var tabSeg: NSSegmentedControl!
  @IBOutlet weak var mainTableView: NSTableView!
  
  var rulesTable = [Rule]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tabSeg.setLabel("Rules", forSegment: 0)
    tabSeg.setLabel("Proxies", forSegment: 1)
    tabSeg.selectedSegment = 0
    mainTableView.delegate = self
    mainTableView.dataSource = self
    loadRulesFromPreferences()
    
    // Do any additional setup after loading the view.
  }
  
  func loadRulesFromPreferences() {
    if let rules = Preferences.sharedInstance.rules {
      rulesTable = Array(rules.values)
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
    } else if selectedIndex == 1{
      

    }
  }

}


extension MainViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return rulesTable.count
  }
}

extension MainViewController: NSTableViewDelegate {
  fileprivate enum CellIdentifiers {
    static let NameCell = "NameCell"
    static let AppNameCell = "AppNameCell"
    static let AppPathCell = "AppPathCell"
    static let ActionCell = "ActionCell"
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var appIcon: NSImage?
    var text: String?
    var cellIdentifier = ""
    let rule = rulesTable[row]
    
    if tableColumn == tableView.tableColumns[0] {
      text = rule.ruleName
      cellIdentifier = CellIdentifiers.NameCell
    } else if tableColumn == tableView.tableColumns[1] {
      text = rule.appName
      if let appPath = rule.appPath {
        appIcon = NSWorkspace.shared().icon(forFile: appPath)
      }
      cellIdentifier = CellIdentifiers.AppNameCell
    } else if tableColumn == tableView.tableColumns[2] {
      text = rule.appPath
      cellIdentifier = CellIdentifiers.AppPathCell
    } else if tableColumn == tableView.tableColumns[3] {
      text = String(describing: rule.isEnabled)
      cellIdentifier = CellIdentifiers.ActionCell
    }
    
    if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text ?? ""
      cell.imageView?.image = appIcon ?? nil
      return cell
    }
    return nil
  }
}

