//
//  File.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/30/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Foundation

class Preferences: NSObject, NSCoding {
  var rules: Dictionary<String, Rule>?
  var isGlobal: Bool?
  static let sharedInstance = Preferences.read()
  
  class func read() -> Preferences {
    if let data = UserDefaults.standard.object(forKey: "local-preferences") as? Data {
      if let pref = NSKeyedUnarchiver.unarchiveObject(with: data) as? Preferences {
        return pref
      }
    }
    return Preferences()
  }
  
  class func checkExist(ruleName: String) -> Bool {
    if let _ = sharedInstance.rules?[ruleName] {
      return true
    }
    return false
  }
  
  
  func addRule(rule: Rule) {
    if let ruleName = rule.ruleName {
      rules?[ruleName] = rule
      sync()
    }
 
  }
  
  func sync() {
    let data = NSKeyedArchiver.archivedData(withRootObject: self)
    UserDefaults.standard.set(data, forKey: "local-preferences")
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(rules, forKey: "rules")
    aCoder.encode(isGlobal, forKey: "isGlobal")
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.rules = aDecoder.decodeObject(forKey: "rules") as? Dictionary<String, Rule>
    self.isGlobal = aDecoder.decodeObject(forKey: "isGlobal") as? Bool
  }
  
  override init() {
    rules = Dictionary<String, Rule>()
    isGlobal = false
  }
}
