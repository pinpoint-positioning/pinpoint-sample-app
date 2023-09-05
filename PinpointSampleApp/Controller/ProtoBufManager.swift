import Foundation
import SwiftProtobuf
import Network
import SDK

class ProtobufManager {
    var storage = LocalStorageManager.shared
    static let shared = ProtobufManager()
    var success = false
    let logger = Logger.shared
    var ppHost = "pinpoint.feste-ip.net"
    var ppPort = 21526
    var connection: NWConnection? // Store the connection as an instance variable
    private var isConnectionEstablished = false

    private init() {
        // Private initializer for singleton pattern
    }
    
    func establishConnection() {
          if isConnectionEstablished {
              print("con exists")
              return
          }
        print("new con")
          
          if !storage.usePinpointRemoteServer {
              ppHost = storage.remoteHost
              ppPort = storage.remotePort
          }
          
          let hostEndpoint = NWEndpoint.Host(ppHost)
          let endpoint = NWEndpoint.hostPort(host: hostEndpoint, port: NWEndpoint.Port(rawValue: UInt16(ppPort))!)
          let parameters = NWParameters.tcp
          
          connection = NWConnection(to: endpoint, using: parameters)
          connection?.stateUpdateHandler = { [weak self] newState in
              switch newState {
              case .ready:
                  self?.isConnectionEstablished = true
                  self?.logger.log(type: .Info, "Connection established.")
              case .failed(let error):
                  self?.isConnectionEstablished = false
                  self?.logger.log(type: .Error, "Connection failed with error: \(error)")
              default:
                  self?.logger.log(type: .Error, "Connection  could not be established")
                  break
              }
          }
          
          connection?.start(queue: .global())
      }
    
    
    func closeConnection() {
        connection?.cancel()
        isConnectionEstablished = false
        logger.log(type: .Info, "Connection closed.")
    }
    
    func sendMessage(x: Double, y: Double, acc: Double, name: String) async throws {
        guard let connection = connection else {
            logger.log(type: .Error, "Failed to create a network connection.")
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
            
            connection.send(content: packedData, completion: .contentProcessed { error in
                if let error = error {
                    self.logger.log(type: .Error, "Failed to send protobuf-message: \(error)")
                } else {
                    self.success.toggle()
                    self.logger.log(type: .Info, "Message sent successfully.")
                }
            })
        } catch {
            self.logger.log(type: .Error, "Failed to send protobuf-message: \(error)")
        }
    }

    
    private func pack(msg: Data) -> Data {
        var header: [UInt8] = [0xFE, 0xED]
        var length: UInt32 = UInt32(msg.count).littleEndian
        let dataLength = withUnsafeBytes(of: &length) { Data($0) }
        
        header.append(contentsOf: dataLength)
        header.append(contentsOf: msg)
        
        return Data(header)
    }
   
}

