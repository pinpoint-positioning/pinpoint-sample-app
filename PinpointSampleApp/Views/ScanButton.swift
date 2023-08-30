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
    @State var mapView:FloorMapView?


    var body: some View {
        ZStack {

            
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
                                    Image("broken-link")
                                        .resizable()
                                        .scaledToFit()
                                        .offset(y:yOffset)
                                        .padding(EdgeInsets(top: 10 , leading: 10, bottom: 10, trailing: 10))
                                        .task {
                                            buttonText = "Disconnect"
                                        }
                                }
                                
                                if (api.scanState == .IDLE && api.generalState != .CONNECTED ) {
                                    
                                    Image(systemName: "dot.radiowaves.left.and.right")
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

//struct SecondaryButtons: View {
//    @Binding var mapView:PositionViewFullScreen?
//    var body: some View {
//        HStack {
//
//            NavigationLink{
//                ConfigView()
//            }
//        label: {
//            ZStack{
//                Circle()
//                    .foregroundColor(CustomColor.pinpoint_orange)
//                    .frame(width: 60, height: 60)
//                    .shadow(radius: 2)
//                Image(systemName: "gear")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.white)
//            }
//
//        }
//        .padding()
//
//            Spacer()
//            NavigationLink{
//                mapView
//            } label: {
//                ZStack{
//                    Circle()
//                        .foregroundColor(CustomColor.pinpoint_orange)
//                        .frame(width: 60, height: 60)
//                        .shadow(radius: 2)
//                    Image("floor-map_3")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//
//                }
//
//            }
//            .padding()
//
//        }
//    }
//}


