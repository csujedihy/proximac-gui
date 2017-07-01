//
//  ClickableImageView.swift
//  proximac-gui
//
//  Created by Yi Huang on 6/30/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Cocoa

class ClickableImageView: NSImageView, NSDraggingSource {
  
  /// Holds the last mouse down event, to track the drag distance.
  var mouseDownEvent: NSEvent?
  var onClick: ((ClickableImageView, NSEvent) -> Void)?
  
  // MARK: - NSDraggingSource
  // Since we only want to copy/delete the current image we register ourselfes
  // for .Copy and .Delete operations.
  func draggingSession(_: NSDraggingSession, sourceOperationMaskFor _: NSDraggingContext) -> NSDragOperation {
    return NSDragOperation.copy.union(.delete)
  }
  
  // Clear the ImageView on delete operation; e.g. the image gets
  // dropped on the trash can in the dock.
  func draggingSession(_: NSDraggingSession, endedAt _: NSPoint, operation: NSDragOperation) {
    if operation == .delete {
      image = nil
    }
  }
  
  // Track mouse down events and safe the to the poperty.
  override func mouseDown(with theEvent: NSEvent) {
    mouseDownEvent = theEvent
    onClick?(self, theEvent)
  }
  
}
