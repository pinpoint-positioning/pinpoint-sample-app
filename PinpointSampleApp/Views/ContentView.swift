//
//  ContentView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI
import CoreData
import CoreBluetooth
import SDK




struct ContentView: View {
    @ObservedObject var btManager = BluetoothManager()
    @State var scanButtonLabel = ""
    @State var autoScroll = true
    
    
    //MARK: - Body
    var body: some View {
        
        ZStack
        {
            VStack {
                HStack {
                    Spacer()
                    Image("ic_launcher_pinpoint_new-playstore")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                    Text("Tracelet Reader")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                    Spacer()
                }
                Divider()
                
                HStack{
                    
                    VStack{
                        
                        // Checkmark for: Bluetooth available
                        HStack
                        {
                            Image(systemName: btManager.powerOn ? SFSymbols.CHECKMARK : SFSymbols.XMARK )
                                .foregroundColor(btManager.powerOn ? Color(.green) : Color(.red) )
                            Text("Bluetooth available")
                            Spacer()
                        }
                        // Checkmark for: isScanning
                        HStack
                        {
                            Image(systemName: btManager.isScanning ? SFSymbols.CHECKMARK : SFSymbols.CHECKMARK_NOT_FILLED )
                                .foregroundColor(btManager.isScanning ? Color(.green) : Color(.red) )
                            Text("Scanning... (\(btManager.remainingTimer))")
                            Spacer()
                        }
                        // Checkmark for: Tracelet in Range
                        HStack
                        {
                            Image(systemName: btManager.traceletInRange ? SFSymbols.CHECKMARK : SFSymbols.XMARK )
                                .foregroundColor(btManager.traceletInRange ? Color(.green) : Color(.red) )
                            Text("Tracelet in range")
                            Spacer()
                        }
                        
                        // Checkmark for: isConnected
                        HStack
                        {
                            Image(systemName: btManager.isConnected ? SFSymbols.CHECKMARK : SFSymbols.XMARK )
                                .foregroundColor(btManager.isConnected ? Color(.green) : Color(.red) )
                            
                            // Combine Label and Device Name with different sizes
                            Text("Connected to: ")
                            +
                            Text("\(btManager.deviceName)")
                                .font(.system(size: 12))
                            
                            Spacer()
                        }
                        
                        // Checkmark for: Service found
                        HStack
                        {
                            Image(systemName: btManager.serviceFound ? SFSymbols.CHECKMARK : SFSymbols.XMARK )
                                .foregroundColor(btManager.serviceFound ? Color(.green) : Color(.red) )
                            Text("UART-service found")
                            
                            Spacer()
                            Image(systemName: btManager.serviceFound ? SFSymbols.CHECKMARK : SFSymbols.XMARK )
                                .foregroundColor(btManager.serviceFound ? Color(.green) : Color(.red) )
                            
                            Text("notify")
                            
                            Spacer()
                        }
                        
                        // Checkmark for: receiving data
                        HStack
                        {
                            Image(systemName: btManager.recievingData ? SFSymbols.CHECKMARK : SFSymbols.XMARK )
                                .foregroundColor(btManager.recievingData ? Color(.green) : Color(.red) )
                            Text("Receiving data")
                            Spacer()
                        }
                    }
                    .padding(EdgeInsets(top:5, leading: 10, bottom:5, trailing: 5))
                    
                }
                
                Divider()
                // Console Output
                ZStack
                {
                    ConsoleTextView(text: btManager.textOutput , autoScroll: autoScroll)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    
                    if (btManager.isScanning) {
                        BusyIndicator()
                    }
                }
                
                // Buttons
                HStack {
                    
                    Button (btManager.isScanning ? "Stop" : "Scan")
                    {
                        if (btManager.isScanning)
                        {
                            btManager.stopScan()
                        } else {
                            btManager.scan()
                        }
                    }
                    .buttonStyle(Buttons.FilledButton())
                    .disabled(btManager.isConnected)
                    
                    Spacer()
                    
                    Button ("Disconnect")
                    {
                        btManager.disconnect()
                    }
                    .buttonStyle(Buttons.FilledButton())
                    .disabled(!btManager.isConnected)
                    
                    Spacer()
                    
                    Text ("Autoscroll")
                    Toggle("", isOn: $autoScroll)
                        .frame(width: 50)
                    
                }
                .padding(.all)
                
            }
            
        }
    }
}

//MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


//MARK: - Additional views

struct BusyIndicator: View {
    var body: some View {
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(0.5)
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint:.gray))
                    .scaleEffect(3)
                Spacer()
                    .frame(height: 50)
                Text("Bring Tracelet closer to the phone")
                    .fontWeight(.bold)
                Spacer()
            }
            
        }
    }
}
