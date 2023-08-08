//
//  DeviceList.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 07.08.23.
//

import SwiftUI
import SDK
import CoreBluetooth

struct DeviceListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var api:API
    @Binding var discoveredDevices:[CBPeripheral]
    
    var body: some View {
        NavigationView{
            VStack {
                if (api.scanState == .SCANNING) {
                    ProgressView("Scanning...")
                        .padding()
                    
                }
                
                List{
                    ForEach(discoveredDevices, id: \.self) { device in
                        HStack{
                            Button(device.name ?? "name not found") {
                                Task {
                                    
                                    do {
                                        let success = try await api.connectAndStartPositioning(device: device)
                                        print(success)
                                    }
                                    catch {
                                        print(error)
                                    }
                                    
                                    
                                    
                                }
                                dismiss()
                            }
                            Spacer()
                            Image(systemName: "eye")
                                .onTapGesture {
                                    // connect and then showme, then disconnect
                                    api.showMe(tracelet: device)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Nearby Tracelets")
        }
    }
}
