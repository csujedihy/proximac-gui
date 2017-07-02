//
//  RuleCardCellView.swift
//  proximac-gui
//
//  Created by Yi Huang on 7/2/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa

class RuleCardCellView: NSTableCellView {
  
  
  @IBOutlet weak var appIconImageView: NSImageView!
  @IBOutlet weak var ruleNameLabel: NSTextField!
  @IBOutlet weak var appNameLabel: NSTextField!
  @IBOutlet weak var appPathLabel: NSTextField!
  @IBOutlet weak var switchView: OGSwitch!
  
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
