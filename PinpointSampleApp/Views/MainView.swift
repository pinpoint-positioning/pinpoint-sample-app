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
import Charts
import CoreLocation
import MapKit
import FilePicker


struct MainView: View {
    
    @State private var showingActions = false
    @ObservedObject var api = API.shared
    @State var siteFile:SiteData?
    @State var siteFileName = ""
    @State var imgH = 0
    @State var imgW = 0
    
    //MARK: - Body
    var body: some View {
        
        
        NavigationStack{
            ZStack{
                Color("pinpoint_background")
                
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack(alignment: .leading){

                            PositionMonitor(siteFile: $siteFile, siteFileName: $siteFileName, imgH: $imgH, imgW: $imgW)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            
                                SiteFileInformationView(siteFile: $siteFile)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                CommandView()
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .blur(radius: api.generalState != .CONNECTED ? 1 : 0)
                                    .overlay(api.generalState != .CONNECTED ? Text("Not connected")
                                        .fontWeight(.semibold): nil)
                                    .disabled(api.generalState != .CONNECTED ? true : false)

                        }
                        
                        .padding()
                    }
                    
                    ScanButton()
                    
                        .background(Color("pinpoint_gray").edgesIgnoringSafeArea(.bottom))
                    
                }
                .navigationTitle("Main")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        NavigationLink {
                            DebugView()
                        } label: {
                            Image(systemName: "ladybug")
                        }
                        
                        NavigationLink {
                            ConfigView()
                        } label: {
                            Image(systemName: "gear")
                        }
                        .disabled(api.generalState == .CONNECTED ? false :true)
                        
                        
                        
                        NavigationLink {
                            SitesList(siteFile: $siteFile, imgW: $imgW, imgH: $imgH, siteFileName: $siteFileName)
                            
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                    }
                }
            }
        }
        .environmentObject(API.shared)
        .environmentObject(Wgs84Reference.shared)
    }

}

//MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(API())
    }
}


//MARK: - Additional views


struct Header: View {
    @EnvironmentObject var api:API
    var body: some View {
        VStack{
            HStack {
                Image("ic_launcher_pinpoint_new-playstore")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .shadow(radius: 5)
                
                Text("Tracelet Reader")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
        }
    }
}






struct PositionView: View{
    
    @EnvironmentObject var api:API
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Response Monitor")
                .fontWeight(.semibold)
            
            Spacer()
            Divider()
            VStack {
                ConsoleTextView(text: api.allResponses , autoScroll: true)
            }
        }
        .frame(minWidth: 0, maxWidth: 400, minHeight: 0, maxHeight: 500)
        .padding()
        .background(CustomColor.pinpoint_background)
    }
}



struct StatesView: View {
    
    @EnvironmentObject var api:API
    @State private var logView = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Debug Monitor")
                .fontWeight(.semibold)
            
            Divider()
            VStack(alignment: .leading) {
                HStack {
                    Text("Connection: ")
                    Image(systemName: "circle.fill")
                        .foregroundColor(api.generalState == .CONNECTED ? Color.green : Color.red )
                }
                HStack {
                    Text("Device: ")
                    Text(String(describing: api.deviceName))
                }
                Divider()
                Text("States")
                    .fontWeight(.semibold)
                HStack {
                    Text("Public: ")
                    Text(String(describing: api.generalState))
                }
                
                HStack {
                    Text("Com: ")
                    Text(String(describing: api.comState))
                }
                HStack {
                    Text("Scan: ")
                    Text(String(describing: api.scanState))
                }
                
                Divider()
                
                Button("Show Logfile")
                {
                    api.openDir()
                    logView = true
                }
                .buttonStyle(.bordered)
                .sheet(isPresented: $logView) {
                    LogView()
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                }
                
            }
            .font(.system(size: 10))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200)
        .padding()
    }
}








struct DeviceListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var api:API
    @Binding var discoveredDevices:[CBPeripheral]
    
    var body: some View {
        VStack {
            Text("Available Tracelets")
                .padding()
                .font(.largeTitle)
            if (api.scanState == .SCANNING) {
                ProgressView("Scanning...")
                    .padding()
                
            }
            
            List{
                ForEach(discoveredDevices, id: \.self) { device in
                    HStack{
                        Button(device.name ?? "name not found") {
                            api.connect(device: device)
                            dismiss()
                        }
                        Spacer()
                        Image(systemName: "eye")
                            .onTapGesture {
                                api.showMe(tracelet: device)
                            }
                    }
                }
            }
        }
    }
}




