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

}
