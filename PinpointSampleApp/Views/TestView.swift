//
//  TestView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 28.04.23.
//

import SwiftUI
import CoreBluetooth
import SDK

struct TestView: View {
    
    @State var discoveredDevices:[CBPeripheral]?
    var newApi: NewApi?
    let bt = BT()
    var body: some View {
        VStack {
            Button ("scan") {
                Task {
                    try await discoveredDevices = bt.scan(timeout:5)
                    print (discoveredDevices)
                }
            }
            if let discoveredDevices = discoveredDevices {
                
            List{
                ForEach(discoveredDevices, id: \.self) { device in
                    HStack{
                        Button(device.name ?? "name not found") {
                            Task {
                                try await bt.connect(device: device)
                            }
                           
                            
                        }
                    }
                }
            }
        }
    }
}
    }


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
