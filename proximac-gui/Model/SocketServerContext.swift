//
//  SocketServerContext.swift
//  proximac-gui
//
//  Created by Yi Huang on 7/3/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class SocketServerContext: NSObject {
  public enum ServerStage {
    case initial
    case accepted
    case forwarding
  }
  
  public enum RemoteStage {
    case initial
    case connecting
    case connected
    case negotiated
    case authenticating
    case authentcated
    case forwarding
  }
  
  
  public struct KernelHandshake {
    var version: Int32
    var address1: UInt32
    var address2: UInt32
    var address3: UInt32
    var address4: UInt32
    var port: UInt16
  }
  
  var serverSocket: GCDAsyncSocket?
  var remoteSocket: GCDAsyncSocket?
  var serverStage: ServerStage = .initial
  var remoteStage: RemoteStage = .initial
  var destinationInfo: KernelHandshake?
  
  init(withServerSocket: GCDAsyncSocket? = nil) {
    self.serverSocket = withServerSocket
  }
  
  func cleanUpServerSocket() {
    self.serverSocket?.setDelegate(nil, delegateQueue: nil)
    self.serverSocket?.userData = nil
    self.serverSocket = nil
  }
  
  func cleanUpRemoteSocket() {
    self.remoteSocket?.setDelegate(nil, delegateQueue: nil)
    self.remoteSocket?.userData = nil
    self.remoteSocket = nil
  }
  
  deinit {
    if let serverSocket = self.serverSocket, serverSocket.isConnected {
      serverSocket.disconnect()
    }
    
    if let remoteSocket = self.remoteSocket, remoteSocket.isConnected {
      remoteSocket.disconnect()
    }
  }
}
