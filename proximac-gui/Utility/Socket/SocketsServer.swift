//
//  SocketsServer.swift
//  proximac-gui
//
//  Created by Yi Huang on 7/3/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class SocketsServer: NSObject {
  fileprivate var listener: GCDAsyncSocket?
  
  override init() {
    
  }
  
  func listenForTrafficFromKernel() {
    listener = GCDAsyncSocket(delegate: self, delegateQueue: .main)
    do {
      try listener?.accept(onPort: 8888)
    } catch _ {
        print("listen failed")
      }
  
  }
  
  deinit {
    if self.listener != nil {
      listener?.disconnect()
    }
  }
  
}

extension SocketsServer: GCDAsyncSocketDelegate {
  fileprivate struct SocketTag {
    static let withKernel = 0
    static let withSOCKS5 = 1
  }
  
  fileprivate struct FixedPacketLength {
    static let fromKernelHandshake: UInt = 22
    static let toSOCKS5Handshake: Int = 3
    static let fromSOCKS5NegotiationReply: UInt = 2
    static let fromSOCKS5RequestReply: UInt = 10
  }
  
  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    Utility.log("host: " + (newSocket.connectedHost ?? "Unknown IP") + ":" + String(newSocket.connectedPort))
    let serverContext = SocketServerContext(withServerSocket: newSocket)
    serverContext.serverStage = .accepted
    newSocket.userData = serverContext
    newSocket.readData(toLength: FixedPacketLength.fromKernelHandshake, withTimeout: -1, tag: 0)
  }
  
  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    if let serverContext = sock.userData as? SocketServerContext {
      switch tag {
      case SocketTag.withKernel:
          if serverContext.serverStage == .accepted {
            let handshake = data.withUnsafeBytes { $0.pointee as SocketServerContext.KernelHandshake}
            serverContext.destinationInfo = handshake
            let remoteSocket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
            remoteSocket.userData = serverContext
            serverContext.remoteSocket = remoteSocket
            serverContext.remoteStage = .connecting
            do {
              try remoteSocket.connect(toHost: "127.0.0.1", onPort: 1080)
            } catch _ {
              Utility.log("connect failed")
            }
          } else if serverContext.serverStage == .forwarding {
            if let remoteSocket = serverContext.remoteSocket {
              remoteSocket.write(data, withTimeout: -1, tag: SocketTag.withSOCKS5)
            } else {
              Utility.log("no remoteSocket found on serverContext")
            }
            sock.readData(withTimeout: -1, tag: SocketTag.withKernel)
          }

      case SocketTag.withSOCKS5:
        if serverContext.remoteStage == .forwarding {
          if let serverSocket = serverContext.serverSocket {
            serverSocket.write(data, withTimeout: -1, tag: SocketTag.withKernel)
          } else {
            Utility.log("no remoteSocket found on serverContext")
          }
          sock.readData(withTimeout: -1, tag: SocketTag.withSOCKS5)
        } else if serverContext.remoteStage == .connected {
          if data[0] == 0x05 && data[1] == 0x00 {
            Utility.log("Negotiation succeeded")
            serverContext.remoteStage = .negotiated
            if let handshake = serverContext.destinationInfo {
              let packet = SocketsServer.generateSOCKS5Packet(fromKernelHandshake: handshake)
              sock.write(packet, withTimeout: -1, tag: SocketTag.withSOCKS5)
            } else {
              Utility.log("No destination info is found")
            }
            sock.readData(toLength: FixedPacketLength.fromSOCKS5RequestReply, withTimeout: -1, tag: SocketTag.withSOCKS5)
          }
        } else if serverContext.remoteStage == .negotiated {
          if SocketsServer.validateSOCKS5RequestReply(packet: data) {
            serverContext.remoteStage = .forwarding
            serverContext.serverStage = .forwarding
            serverContext.serverSocket?.readData(withTimeout: -1, tag: SocketTag.withKernel)
            sock.readData(withTimeout: -1, tag: SocketTag.withSOCKS5)
          }
        }
      default:
        Utility.log("unknown tag ERROR")
      }
    }
  }
  
  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError: Error?) {
    Utility.log("socketDidDisconnect")
    if let serverContext = sock.userData as? SocketServerContext{
      if sock == serverContext.serverSocket {
        Utility.log("kernel side close")
        Utility.log("sock status = " + String(sock.isDisconnected))
        serverContext.remoteSocket?.disconnectAfterReadingAndWriting()

      } else if sock == serverContext.remoteSocket {
        Utility.log("remote side close")
        Utility.log("sock status = " + String(sock.isDisconnected))
        serverContext.serverSocket?.disconnectAfterReadingAndWriting()
      } else {
        Utility.fatal("sock is not found")
      }
    
    }
  }
  
  func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag: Int) {
    Utility.log("didWriteDataWithTag = " + String(didWriteDataWithTag))
  }
  
  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    if let serverContext = sock.userData as? SocketServerContext {
      serverContext.remoteStage = .connected
      Utility.log("connected to " + host + ":" + String(port))
      sock.readData(toLength: FixedPacketLength.fromSOCKS5NegotiationReply, withTimeout: -1, tag: SocketTag.withSOCKS5)
      var packetData = [UInt8](repeating: 0, count: FixedPacketLength.toSOCKS5Handshake)
      packetData[0] = 5
      packetData[1] = 1
      packetData[2] = 0
      let data = Data(bytes: packetData)
      sock.write(data, withTimeout: -1, tag: SocketTag.withSOCKS5)
    }

  }
  
}

extension SocketsServer {
  class func generateSOCKS5Packet(fromKernelHandshake handshake: SocketServerContext.KernelHandshake) -> Data {
    var data = Data()
    data.append(contentsOf: [0x05, 0x01, 0x00])
    var port = handshake.port.bigEndian
    var handshakeStruct = handshake
    if handshake.version == AF_INET {
      data.append(0x01)
      var v4address = handshakeStruct.address1.bigEndian
      data.append(UnsafeBufferPointer(start: &v4address, count: 1))
      data.append(UnsafeBufferPointer(start: &port, count: 1))
      Utility.log("socks5request.size = " + String(data.count))
    } else if handshake.version == AF_INET6 {
      data.append(0x04)
      data.append(UnsafeBufferPointer(start: &handshakeStruct.address1, count: 4))
      data.append(UnsafeBufferPointer(start: &port, count: 1))
      Utility.log("socks5request.size = " + String(data.count))
    }
    return data
  }
  
  /* REP value table
  o  X'00' succeeded
  o  X'01' general SOCKS server failure
  o  X'02' connection not allowed by ruleset
  o  X'03' Network unreachable
  o  X'04' Host unreachable
  o  X'05' Connection refused
  o  X'06' TTL expired
  o  X'07' Command not supported
  o  X'08' Address type not supported
  o  X'09' to X'FF' unassigned
  */
  
  class func validateSOCKS5RequestReply(packet: Data) -> Bool {
    let value = packet[1]
    switch value {
      case 0x00:
        return true
      case 0x01:
        Utility.log("general SOCKS server failure")
      case 0x02:
        Utility.log("connection not allowed by ruleset")
      case 0x03:
        Utility.log("Network unreachable")
      case 0x04:
        Utility.log("Host unreachable")
      case 0x05:
        Utility.log("Connection refused")
      case 0x06:
        Utility.log("TTL expired")
      case 0x07:
        Utility.log("Command not supported")
      case 0x08:
        Utility.log("Address type not supported")
      default:
        Utility.log("Unassigned REP value")
        break
    }
    return false
  }
}
