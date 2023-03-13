//
//  ContentView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI
import CoreData
import CoreBluetooth


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
                        
                        HStack
                        {
                            Image(systemName: btManager.powerOn ? "checkmark.circle.fill" : "checkmark.circle.badge.xmark")
                            Text("Bluetooth is on")
                            Spacer()
                        }
                        HStack
                        {
                            Image(systemName: btManager.isScanning ? "checkmark.circle.fill" : "checkmark.circle")
                            Text("Scanning...")
                            Spacer()
                        }
                        
                        HStack
                        {
                            Image(systemName: btManager.traceletInRange ? "checkmark.circle.fill" : "checkmark.circle.badge.xmark")
                            Text("Tracelet in range")
                            Spacer()
                        }
                        
                        HStack
                        {
                            Image(systemName: btManager.isConnected ? "checkmark.circle.fill" : "checkmark.circle.badge.xmark")
                            
                            // Combine Label and Device Name with different sizes
                            Text("Connected to: ")
                            +
                            Text("\(btManager.deviceName)")
                                .font(.system(size: 12))
                            
                            Spacer()
                        }
                        
                        HStack
                        {
                            Image(systemName: btManager.serviceFound ? "checkmark.circle.fill" : "checkmark.circle.badge.xmark")
                            Text("UART-service found")
                            Spacer()
                        }
                        
                        HStack
                        {
                            Image(systemName: btManager.recievingData ? "checkmark.circle.fill" : "checkmark.circle.badge.xmark")
                            Text("Receiving data")
                            Spacer()
                        }
                        
                     
                    }
                    .padding(EdgeInsets(top:5, leading: 10, bottom:5, trailing: 5))

                }

                Divider()

                ZStack
                {
                    ConsoleTextView(text: btManager.textOutput ?? "", autoScroll: autoScroll)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))

                    if (btManager.isScanning) {
                        BusyIndicator()
                        
                    }
                }
                
                
                HStack {
                    
                    Button (btManager.isScanning ? "Stop Scan" : "Scan")
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
