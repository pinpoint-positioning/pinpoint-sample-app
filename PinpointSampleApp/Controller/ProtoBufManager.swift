//
//  ProtoBufManager.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 21.08.23.
//

import Foundation
import SwiftProtobuf
import Network
import SwiftUI
import SDK

class ProtobufManager: ObservableObject {
    let storage = LocalStorageManager()
    static let shared = ProtobufManager()

    let logger = Logger.shared
    let ppHost = "pinpoint.feste-ip.net" //"pp-chris.feste-ip.net"//
    let ppPort = 21526 //14175 //

    
    private var connection: NWConnection?
    
    private func establishConnection() {
        
        
        let hostEndpoint = NWEndpoint.Host(storage.usePinpointRemoteServer ? ppHost : storage.remoteHost)
        let endpoint = NWEndpoint.hostPort(host: hostEndpoint, port: NWEndpoint.Port(rawValue: UInt16(storage.usePinpointRemoteServer ? ppPort : storage.remotePort))!)
        let parameters = NWParameters.tcp.copy()
       // parameters.requiredInterfaceType = .wifi // Careful if host will be public available
        
        connection = NWConnection(to: endpoint, using: parameters)
    }
    
    func sendMessage(x: Double, y: Double, acc: Double, name: String) throws {
        establishConnection()
        
        guard let connection = connection else {
            logger.log(type: .Error, "Failed to create a network connection.")
            return
        }
        
        let currentTime = Date()
        let timestamp = Google_Protobuf_Timestamp(seconds: Int64(currentTime.timeIntervalSince1970))
        
        var traceletMessage = Tracelet_TraceletToServer()
        traceletMessage.id = 1
        traceletMessage.deliveryTs = timestamp
        if name == "" {
            traceletMessage.traceletID = UIDevice.current.name
        } else {
            traceletMessage.traceletID = name
        }
        traceletMessage.ignition = true
        
        var location = Tracelet_TraceletToServer.Location()
        location.uwb.valid = true
        location.uwb.x = x
        location.uwb.y = y
        location.uwb.z = 1.0
        location.uwb.siteID = 1234
        location.uwb.eph = acc
        location.uwb.locationSignature = 1
        traceletMessage.type = .location(location)
        
        do {
            let binaryData = try traceletMessage.serializedData()
            let packedData = pack(msg: binaryData)
            
            connection.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    // Send the binary data to the server
                    connection.send(content: packedData, completion: .contentProcessed { error in
                        if let error = error {
                            self.logger.log(type: .Error, "Failed to send protobuf-message: \(error)")
                         
                            
                        } else {
                            print("Message sent successfully.")
                        }
                        connection.cancel()
                    })
                default:
                    return
                }
            }
            
            connection.start(queue: .global())
        } catch {
            self.logger.log(type: .Error, "Failed to send protobuf-message: \(error)")
        }
    }
    
    private func pack(msg: Data) -> Data {
        let header: [UInt8] = [0xFE, 0xED]
        var length: UInt32 = UInt32(msg.count).littleEndian 
        let dataLength = withUnsafeBytes(of: &length) { Data($0) }
        
        return Data(header + dataLength + msg)
    }
}

