//
//  Rule.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/30/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Foundation

class Rule: NSObject, NSCoding {
  var ruleName: String?
  var appName: String?
  var appPath: String?
  var isEnabled: Bool?
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(ruleName, forKey: "ruleName")
    aCoder.encode(appName, forKey: "appName")
    aCoder.encode(appPath, forKey: "appPath")
    aCoder.encode(isEnabled, forKey: "isEnabled")
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.ruleName = aDecoder.decodeObject(forKey: "ruleName") as? String
    self.appName = aDecoder.decodeObject(forKey: "appName") as? String
    self.appPath = aDecoder.decodeObject(forKey: "appPath") as? String
    self.isEnabled = aDecoder.decodeObject(forKey: "isEnabled") as? Bool
  }
  
  func destroy() {
    if let ruleName = ruleName {
      Preferences.sharedInstance.delete(ruleName: ruleName)
    }
  }
  
  init(ruleName: String, appName: String, appPath: String, isEnabled: Bool) {
    self.ruleName = ruleName
    self.appName = appName
    self.isEnabled = isEnabled
    self.appPath = appPath
  }
}
