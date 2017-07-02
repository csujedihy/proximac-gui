//
//  File.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/30/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Foundation

class Preferences: NSObject, NSCoding {
  dynamic var rules: Dictionary<String, Rule>?
  var isGlobal: Bool?
  var isEnabled: Bool?
  var socks5ServerIP: String?
  var socks5ServerPort: Int16?
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
  
  func toggle(_ status: Bool, callback: ((Preferences) -> Void)? = nil) {
    isEnabled = status
    sync()
    callback?(self)
  }
  
  func addRule(rule: Rule) {
    if let ruleName = rule.ruleName {
      rules?[ruleName] = rule
      sync()
    }
  }
  
  func delete(ruleName: String) {
    rules?.removeValue(forKey: ruleName)
    sync()
  }
  
  func sync() {
    let data = NSKeyedArchiver.archivedData(withRootObject: self)
    UserDefaults.standard.set(data, forKey: "local-preferences")
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(rules, forKey: "rules")
    aCoder.encode(isGlobal, forKey: "isGlobal")
    aCoder.encode(isEnabled, forKey: "isEnabled")
    aCoder.encode(socks5ServerIP, forKey: "socks5ServerIP")
    aCoder.encode(socks5ServerPort, forKey: "socks5ServerPort")
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.rules = aDecoder.decodeObject(forKey: "rules") as? Dictionary<String, Rule>
    self.isGlobal = aDecoder.decodeObject(forKey: "isGlobal") as? Bool
    self.isEnabled = aDecoder.decodeObject(forKey: "isEnabled") as? Bool
    self.socks5ServerIP = aDecoder.decodeObject(forKey: "socks5ServerIP") as? String
    self.socks5ServerPort = aDecoder.decodeObject(forKey: "socks5ServerPort") as? Int16
  }
  
  override init() {
    rules = Dictionary<String, Rule>()
    isGlobal = false
  }
}
