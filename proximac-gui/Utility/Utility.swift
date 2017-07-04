//
//  Utility.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/30/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa

class Utility {
  class func openFilePanel(_ title: String, isDir: Bool, baseDir: URL? = nil, ok: @escaping(URL) -> Void) {
    let panel = NSOpenPanel()
    panel.title = title
    panel.canCreateDirectories = false
//    panel.canChooseFiles = !isDir
    panel.canChooseDirectories = isDir
    panel.resolvesAliases = true
    panel.allowsMultipleSelection = false
    if let baseDir = baseDir {
      panel.directoryURL = baseDir
    }
    panel.begin() { result in
      if result == NSFileHandlingPanelOKButton, let url = panel.url {
        ok(url)
      }
    }
  }

  
  static func showAlert(_ content: String, arguments: [CVarArg]? = nil, style: NSAlertStyle = .critical) {
    let alert = NSAlert()
    switch style {
    case .critical:
      alert.messageText = "Error"
    case .informational:
      alert.messageText = "Information"
    case .warning:
      alert.messageText = "Warning"
    }
    
    if let stringArguments = arguments {
      alert.informativeText = String(format: content, arguments: stringArguments)
    } else {
      alert.informativeText = String(format: content)
    }
    
    alert.alertStyle = style
    alert.runModal()
  }

  static func validatePortNumberString(_ portToValidate: String) -> Bool {
    if let port = Int(portToValidate), port > 0 && port < 65536 {
      return true
    }
    return false
  }
  
  static func log(_ message: String) {
    NSLog("%@", message)
  }
  
  static func assert(_ expr: Bool, _ errorMessage: String, _ block: () -> Void = {}) {
    if !expr {
      NSLog("%@", errorMessage)
      showAlert("fatal_error", arguments: [errorMessage])
      block()
      exit(1)
    }
  }
  
  static func fatal(_ message: String, _ block: () -> Void = {}) -> Never {
    NSLog("%@\n", message)
    NSLog(Thread.callStackSymbols.joined(separator: "\n"))
    showAlert("fatal_error", arguments: [message])
    block()
    exit(1)
  }
  
  static func validateIpAddress(_ ipToValidate: String) -> Bool {
    
    var sin = sockaddr_in()
    var sin6 = sockaddr_in6()
    
    if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
      // IPv6 peer.
      return true
    }
    else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
      // IPv4 peer.
      return true
    }
    
    return false;
  }
  
}

