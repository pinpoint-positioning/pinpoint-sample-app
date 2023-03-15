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
    @Published var textOutput = String()
    
    //States -- Really false in init?
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var powerOn = false
    @Published var traceletInRange = false
    @Published var serviceFound = false
    @Published var recievingData = false
    @Published var deviceName = ""
    @Published var subscribedToNotifiy = false
    
    
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var tracelet: CBPeripheral? = nil
    let decoder = Decoder()
    
    // Variables for Scan-Timeout-Timer
    var timer: Timer?
    var runCount = 0
    var timeout = 30
    @Published var remainingTimer = 0
    
    
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
        
        
        //Start Timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        

        //Start async timer thread for scan-timeout
        // Stop scanning afer X seconds
       // DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
        //    self.stopScan()
       // }
    }
    
    
    
    func stopScan() {
        
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect() {
        
        // Make sure the device the should be connected is the identified tracelet
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
    
    
 // Scan-Timeout Timer settings
    @objc func fireTimer() {
        runCount += 1
        remainingTimer = timeout - runCount

//1 Run = 1 sec.  30 runs = 30 secs
        if (runCount == timeout || !isScanning) {
            timer?.invalidate()
            remainingTimer = timeout
            stopScan()
            if (!isScanning) {runCount = 0}
        }
    }
    
    
    
    
    //MARK: - Delegate Functions
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            powerOn = true
            break
        case .poweredOff:
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
        
        
        
        
        // Needs to be improved!!
        // Connect either to Dummy(df2b) or "black Tracelet" (6ec6)
        if (peripheral.name?.contains("df2b") ?? false && inProximity(RSSI) || peripheral.name?.contains("6ec6") ?? false && inProximity(RSSI))
        {
            //   if (peripheral.identifier == UUIDs.traceletDummyUUID && inProximity(RSSI)) {
            
            
            //Set State
            traceletInRange = true
            // / If tracelet is found,save object in "peripheral"
            tracelet = peripheral
            
            //Stop Scan
            centralManager.stopScan()
            isScanning = false
            
            //Attempt to connect
            connect()
            
        }
    }
    
    
    
    // Delegate - Called when connection was successful
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == tracelet {
            // Set State
            isConnected = true
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
                    serviceFound = true
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
                
                // Subscribe to notify of charateristic
                if characteristic.uuid == UUIDs.traceletTxChar {
                    
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                        subscribedToNotifiy = true
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
            print("no data")
            return
        }
        
        // Get TX  value
        if characteristic.uuid == UUIDs.traceletTxChar {
            // Set State
            recievingData = true
            
            do {
                let validatedMessage = try decoder.ValidateMessage(of: data)
                let localPosition = try TagPositionResponse(of: validatedMessage)
                
                let xPos = localPosition.xCoord
                let yPos = localPosition.yCoord
                let zPos = localPosition.zCoord
                // let covXx = localPosition.covXx
                // let covXy = localPosition.covXy
                // let covYy = localPosition.covYy
                let siteId = localPosition.siteID
                // let signature = localPosition.signature
                
                textOutput = "X: \(xPos) Y: \(yPos) Z: \(zPos) site: \(siteId)\n\n"
                
            }catch{
                
                textOutput = "\(error) \n"
            }
        }
    }
    
    
    
    // Delegate - Called when disconnected
    // Improve: Reset all states
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        traceletInRange = false
        serviceFound = false
        recievingData = false
        subscribedToNotifiy = false
        deviceName = ""
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
