//
//  ContentView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI
import CoreData
import CoreBluetooth
import Charts
import CoreLocation
import MapKit
import FilePicker
import SDK


struct MainView: View {
    
    @State private var showingActions = false
    @ObservedObject var api = API.shared
    @State var siteFile:SiteData?
    @State var siteFileName = ""
    
    //MARK: - Body
    var body: some View {
        
        
        NavigationStack{
            ZStack{
                Color("pinpoint_background")
                
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack(alignment: .center){
                            StatusCircle()
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        
                        
                                SiteFileInformationView(siteFile: $siteFile)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                        }
                        
                        .padding()
                    }
                    
                    ScanButton(mapView:PositionViewFullScreen(siteFile: $siteFile, siteFileName: $siteFileName))
                    
                        .background(Color("pinpoint_gray").edgesIgnoringSafeArea(.bottom))
                    
                }
                .safeAreaInset(edge: .top, content: {
                    Color.clear
                        .frame(height: 0)
                        .background(Color("pinpoint_gray"))
                        .border(.black)
                })
                .navigationTitle("Tracelet Reader")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            DebugView()
                        } label: {
                            Image(systemName: "ladybug")
                                .foregroundColor(.black)
                        }

                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink {
                            InfoView()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.black)
                        }
                        
                    }
                }
            }
        }
        .environmentObject(API.shared)
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
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .background(Color("pinpoint_background"))
        .foregroundColor(Color("pinpoint_gray"))

    }
}



struct StatesView: View {
    
    @EnvironmentObject var api:API
    @State private var logView = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Debug")
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
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .background(Color("pinpoint_background"))
        .foregroundColor(Color("pinpoint_gray"))
        
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
                            //api.connectAndStartPositioning(device: device)
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
                                api.showMe(tracelet: device)
                            }
                    }
                }
            }
        }
    }
}







