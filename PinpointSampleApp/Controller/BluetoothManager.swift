//
//  BluetoothManager.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import Foundation
import CoreBluetooth
import SDK


class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    
    
    // Properties
    @Published var textOutput:String?
    
    //States -- Really false in init?
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var powerOn = false
    @Published var traceletInRange = false
    @Published var serviceFound = false
    @Published var recievingData = false
    @Published var deviceName = ""

        
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var tracelet: CBPeripheral? = nil
    
 
    

    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        
        
    }
    

    func scan()
    {
        isScanning = true
        //Set to true, to continously searching for devices. Helpful when device is out of range and getting closer (RSSI)
        let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)]
        
        //Initiate BT Scan and start spinner
        centralManager.scanForPeripherals(withServices: nil, options: options)
        textOutput = Strings.SCAN_STARTED
    }
    
    
    func stopScan() {
        
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect() {
        
        if let foundTracelet = tracelet{
            centralManager.connect(foundTracelet, options: nil)
        }
    }
    
    func disconnect() {
        centralManager.cancelPeripheralConnection(tracelet!)
        peripheral = nil
        
        }
    
    
    
    // Use RSSI to connect only when close ( > -50 db).
    // Sometimes RSSI returns max value 127. Excluded it for now.
    // Maybe include PowerTX Level- -> TBD
    
    func inProximity(_ RSSI: NSNumber) -> Bool {
        if (RSSI.intValue > -50 && RSSI != 127){
            return true
        } else {
            return false
        } 
    }
    
    
    
    
    
    
    
    
    //MARK: - Delegate Functions
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            textOutput = Strings.BLUETOOTH_IS_ON
            powerOn = true
            break
        case .poweredOff:
            textOutput = Strings.BLUETOOTH_IS_OFF
            powerOn = false
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        default:
            break
        }
    }
    
    
    
    // Scantime ??
    
    // Delegate - Called when scan has results
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        peripheral.delegate = self
        
        
        // If tracelet is found, enable connect Button and save object in "peripheral"
        // Use RSSI to connect only when close ( > -50 db).
        // Sometimes RSSI returns max value 127. Excluded it for now.
        
        

        if (peripheral.identifier == UUIDs.traceletDummyUUID && inProximity(RSSI)) {
            
            
            //Set State
            traceletInRange = true
            // Save tracelet object
            tracelet = peripheral
            
            centralManager.stopScan()
            
            isScanning = false
            
            
            // ### Debug part ### //
            textOutput = Strings.TRACELET_FOUND
            // ### Debug part end ### //
            
            //Attempt to connect
            connect()
            
        }
    }
    

    
    // Delegate - Called when connection was successful
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == tracelet {
            // Set State
            isConnected = true
            textOutput = Strings.DEVICE_CONNECTED
            deviceName = peripheral.name ?? "unkown"
            
            // Discover UART Service
            peripheral.discoverServices([UUIDs.traceletNordicUARTService])

            
        }
    }
    
    
    // Delegate - Called when services are discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                
                // Discover UART Service
                if service.uuid == UUIDs.traceletNordicUARTService{
                    print(Strings.UART_SERVICE_FOUND)
                    serviceFound = true
                    textOutput = Strings.UART_SERVICE_FOUND
                }
                
                peripheral.discoverCharacteristics([UUIDs.traceletRxChar,UUIDs.traceletTxChar], for: service)
                
                return
            }
        }
    }
    
    
    
    // Delegate - Called when chars are discovered
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                
                if characteristic.uuid == UUIDs.traceletTxChar {
                    print("TX characteristic found")
                    
                    if characteristic.properties.contains(.notify) {
                        print("\(characteristic.uuid): properties contains .notify")
                        peripheral.setNotifyValue(true, for: characteristic)
                    }else{
                        print("Characteristic has no notify property")
                    }
                }
            }
        }
    }
    
    
    // Delegate - Called when char value has updated for defined char
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,error: Error?) {
        
        
        guard let data = characteristic.value else {
            // no data transmitted, handle if needed
            
            print("no data") // Just to remove the error
            return
        }
        print(data) // Just to remove the "unused" error
        // Get TX  value
        if characteristic.uuid == UUIDs.traceletTxChar {
            recievingData = true
            
// Print RAW Hex data as String to Console:
//print((characteristic.value!.hexEncodedString() ))
            
       // Raw bytes reading TEST
            
            
            withUnsafeBytes(of: data) { pointerBuffer in
                for byte in pointerBuffer {
                    print(byte)
                }
            }
            
//        Byte0: 7F // START_BYTE
//        Byte1: 97
//        Byte2: 55
//        Byte3: 00
//        Byte4: 1D
//        Byte5: 00
//        Byte6: 0A
//        Byte7: 00
//        Byte8: 00
//        Byte9: 00
//        Byte10: 00
//        Byte11: 00
//        Byte12: 00
//        Byte13: 00
//        Byte14: 00
//        Byte15: 00
//        Byte16: 00
//        Byte17: 00
//        Byte18: 00
//        Byte19: 00
//        Byte20: 7E
//        Byte21: 51
//        Byte22: FD
//        Byte23: BB
//        Byte24: 01
//        Byte25: B2
//        Byte26: 38
//        Byte27: 4D
//        Byte28: 21
//        Byte29: 53
//        Byte30: 8F // END_BYTE
//PREFIX_BYTE: 1B
            
//XOR_BYTE_MASK = 0x20
//     COMMAND_ACTIVATE(0x01),
//     COMMAND_DEACTIVATE(COMMAND_ACTIVATE.hexValue),

//     COMMAND_ACTIVATE_TAG30(0x05),

//     COMMAND_GET_STATUS(0x12),
//     COMMAND_GET_STATUS_RESPONSE(0x92.toByte()),

//     COMMAND_DISTANCE(0x81.toByte()),
//     COMMAND_POSITION(0x97.toByte())
            
            
            var hexArray: [String] = []

            for i in characteristic.value!.indices {
                let intToHex = String(format:"%02X", characteristic.value![i])
                hexArray.append(intToHex)
            }
            
            if (hexArray[0] == "7F"){
                
                print ( "Message starting with Start Byte: Continue \n\n")
            
                if (hexArray.last == "8F")
                {
                    print( "Message ending with End Byte: Continue \n\n")
                    if (hexArray.count == 31)
                    {
                        print("Message has \(hexArray.count) Bytes")
                    }
                    else if (hexArray.count == 32)
                    {
                        print("Message has \(hexArray.count) Bytes")
                    }
                    
                    hexArray.remove(at: 0)
                    hexArray.remove(at: hexArray.count-1)
                    self.textOutput = "\(hexArray)\n\n"
                    print ("\(hexArray)\n\n")
                }else{
                    print("Message has no End Byte: ignoring")
                }
            }else{
                print( "Message has no Start Byte: ignoring")
            }
        }
    }
    
    
    
    // Delegate - Called when disconneccted
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        traceletInRange = false
        serviceFound = false
        recievingData = false
        textOutput = Strings.DEVICE_DISCONNECTED
    }
    
    
    //Failsafe Delegate Functions
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        textOutput = Strings.CONNECTION_FAILED
    }

}



//MARK: - Extensions


// Extension to decode hex of type DATA
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
