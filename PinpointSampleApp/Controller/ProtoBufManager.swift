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

class ProtobufManager: ObservableObject {
    
    static let shared = ProtobufManager()
    @AppStorage("remote-host") var remoteHost = ""
    @AppStorage("remote-port") var remotePort = 8081

    
    private var connection: NWConnection?
    
    private func establishConnection() {
        let hostEndpoint = NWEndpoint.Host(remoteHost)
        let endpoint = NWEndpoint.hostPort(host: hostEndpoint, port: NWEndpoint.Port(rawValue: UInt16(remotePort))!)
        let parameters = NWParameters.tcp.copy()
       // parameters.requiredInterfaceType = .wifi // Careful if host will be public available
        
        connection = NWConnection(to: endpoint, using: parameters)
    }
    
    func sendMessage(x: Double, y: Double, acc: Double, name: String) throws {
        establishConnection()
        
        guard let connection = connection else {
            print("Failed to create a network connection.")
            return
        }
        
        let currentTime = Date()
        let timestamp = Google_Protobuf_Timestamp(seconds: Int64(currentTime.timeIntervalSince1970))
        
        var traceletMessage = Tracelet_TraceletToServer()
        traceletMessage.id = 1
        traceletMessage.deliveryTs = timestamp
        traceletMessage.traceletID = name
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
                            print("Failed to send the message: \(error)")
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
            print("Error: \(error)")
        }
    }
    
    private func pack(msg: Data) -> Data {
        let header: [UInt8] = [0xFE, 0xED]
        var length: UInt32 = UInt32(msg.count).littleEndian 
        let dataLength = withUnsafeBytes(of: &length) { Data($0) }
        
        return Data(header + dataLength + msg)
    }
}

