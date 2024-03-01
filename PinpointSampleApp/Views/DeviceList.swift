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
    let logger = Logging.shared
    @State var eyeIconOpacity = 1.0
    
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
                                        logger.log(type: .info, "ConnectAndStartPositioning OK")
                                    }
                                    catch {
                                        logger.log(type: .error, error.localizedDescription)
                                    }
                                    
                                    
                                    
                                }
                                dismiss()
                            }
                            Spacer()
                            
                            // Eye will fadeInOut when showme is ongoing
                            Image(systemName: "eye")
                                .foregroundColor(.black)
                                .onTapGesture {
                                    // connect and then showme, then disconnect
                                    Task {
                                        do {
                                            try await api.connect(device: device)
                                        } catch {
                                            logger.log(type: .error, error.localizedDescription)
                                        }
                                        api.showMe(tracelet: device)
                                        
                                        
                                        try await _Concurrency.Task.sleep(nanoseconds: 2_000_000_000)
          
                                        
                                        api.disconnect()
                                    }
                                    
                                        
                                }
                            
                        }
                    
                    }
                }
            }
            .navigationTitle("Nearby Tracelets")
        }
    }

}
