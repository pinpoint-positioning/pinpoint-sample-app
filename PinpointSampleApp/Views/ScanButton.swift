//
//  ScanButton.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 10.05.23.
//

import SwiftUI
import SDK
import CoreBluetooth

struct ScanButton:View {
    @EnvironmentObject var api:API
    @State private var showingScanResults = false
    @State private var discoveredDevices:[CBPeripheral] = []
    @State var yOffset = -40.0
    @State var buttonText = ""

    
    
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                .ignoresSafeArea()
                .foregroundColor(CustomColor.pinpoint_gray)
            
            Button {
                
                if (api.scanState == .SCANNING)
                {
                    api.stopScan()
                }
                if (api.generalState == .CONNECTED)
                {
                    api.disconnect()
                }
                
                else {
                    discoveredDevices = []
                    showingScanResults.toggle()
                    
                    api.scan(timeout: 3) { deviceList in
                        
                        discoveredDevices = deviceList
                    }
                }
                
            }
        label: {
            VStack{
                ZStack {
                    Circle()
                        
                        .foregroundColor(CustomColor.pinpoint_background)
                        .frame(width: 80, height: 80)
                        .offset(y:yOffset)
                    
                    
                    Circle()
                        .foregroundColor(CustomColor.pinpoint_orange)
                        .frame(width: 60, height: 60)
                        .offset(y:yOffset)
                        .overlay {
                            if (api.scanState == .SCANNING)
                            {
                                Image(systemName: "wifi.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.red)
                                    .offset(y:yOffset)
                                    .frame(width: 60)
                                
                                    .padding(EdgeInsets(top: 3 , leading: 3, bottom: 3, trailing: 3))
                                    .task {
                                        buttonText = "Stop Scan"
                                    }
                            }
                            if (api.generalState == .CONNECTED )
                            {
                                Image("disconnected-chains")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.red)
                                    .offset(y:yOffset)
                                    .padding(EdgeInsets(top: 10 , leading: 10, bottom: 10, trailing: 10))
                                    .task {
                                        buttonText = "Disconnect"
                                    }
                            }
                            
                            if (api.scanState == .IDLE && api.generalState != .CONNECTED ) {
                                
                                Image(systemName: "wifi")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .offset(y:yOffset)
                                
                                    .padding(EdgeInsets(top: 3 , leading: 3, bottom: 3, trailing: 3))
                                    .task {
                                        buttonText = "Scan"
                                    }
                            }
                        }
                    
                    Text(buttonText)
                        .offset(y:20)
                        .foregroundColor(.white)
                   
                }
            }
            
        }
            
            // ScanList menu
        .sheet(isPresented: $showingScanResults) {
            DeviceListView(discoveredDevices: $discoveredDevices)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
            
            
        }
   
    }
}

struct ScanButton_Previews: PreviewProvider {
    static var previews: some View {
        ScanButton()
            .environmentObject(API())
    }
}
