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

struct MainView: View {
    let locations = AsyncLocationStream()
    var body: some View {
        VStack
        {
            Header()
            TabView{
                ContentView()
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }
                
                DebugView()
                    .tabItem {
                        Label("Debug", systemImage: "ladybug.fill")
                    }
                
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                
            }
            .environmentObject(API.shared)
            .environmentObject(Wgs84Reference.shared)
        }
        .padding()

    }
}


struct MapView: View {
    
    @EnvironmentObject var api:API
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    //MARK: - Body
    var body: some View {

        
        Map(coordinateRegion: $region)
            
    }
}






struct ContentView: View {

    @State private var showingActions = false
    @EnvironmentObject var api:API
    
    //MARK: - Body
    var body: some View {
        
        VStack {
            ScrollView {
                VStack(alignment: .leading){
                    HStack {
                        PositionMonitor()
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    HStack{
                        StatusView()
                            .blur(radius: api.generalState != .CONNECTED ? 1 : 0)
                            .overlay(api.generalState != .CONNECTED ? Text("Not connected")
                                .fontWeight(.semibold): nil)
                            
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .disabled(api.generalState != .CONNECTED ? true : false )
                        
                        CommandView()
                            .blur(radius: api.generalState != .CONNECTED ? 1 : 0)
                            .overlay(api.generalState != .CONNECTED ? Text("Not connected")
                                .fontWeight(.semibold): nil)
                            .disabled(api.generalState != .CONNECTED ? true : false)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
            }
            
            
            //Buttons
            //                HStack {
            CommandButtons()
            //
            //                    Button
            //                    {
            //                        showingActions.toggle()
            //                    } label: {
            //                        HStack {
            //                            Text("Cmds")
            //                            Image(systemName: "chevron.up")
            //                        }
            //                }
            //                .buttonStyle(.borderedProminent)
            //            }
            //        }
            //            .padding()
            //
            //        // Actions menu
            //        .sheet(isPresented: $showingActions) {
            //            ActionsModalView()
            //                .presentationDetents([.medium, .large])
            //                .presentationDragIndicator(.visible)
        }
    }
}



//MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(API())
    }
}


//MARK: - Additional views


struct CommandButtons:View {
    @EnvironmentObject var api:API
    @State private var showingScanResults = false
    @State private var discoveredDevices:[CBPeripheral] = []
    
    var body: some View {
        HStack {
            Button (api.scanState == .SCANNING ? "Stop" : "Scan")
            {
                if (api.scanState == .SCANNING)
                {
                    api.stopScan()
                } else {
                    showingScanResults.toggle()
                    discoveredDevices = []
                    api.scan(timeout: 5) { deviceList in
                        discoveredDevices = deviceList
                    }
                }
                
            }
            .buttonStyle(.bordered)
            .disabled(api.generalState == .CONNECTED)
            
            // ScanList menu
            .sheet(isPresented: $showingScanResults) {
                DeviceListView(discoveredDevices: $discoveredDevices)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            
            
            Button ("Disconnect")
            {
                api.disconnect()
            }
            .buttonStyle(.bordered)
            .disabled(api.generalState == .CONNECTED ? false : true)
            Spacer()
        }
        .padding()
    }
}



struct ActionsModalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api:API

    
    var body: some View {
        NavigationStack{
            let state = "State: \(api.generalState)"
            Text(state)
            List
            {
                Button("GetStatus")
                {
                    api.requestStatus()
                    dismiss()
                }
                
                
                Button("StartPositioning")
                {
                    Task {
                        api.requestPosition()
                    }
                }
                
                Button("GetVersion")
                {
                    dismiss()
                }
                
                
                
                Button("StopPositioning")
                {
                    api.stopPositioning()
                    dismiss()
                }

              Button("SetInterval")
                {
                 
                }
   

                Button("ShowMe")
                {
                    if let tracelet = api.connectedTracelet {
                        api.showMe(tracelet: tracelet)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Actions")
        }
    }
}




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


struct DebugView: View{
    
    @EnvironmentObject var api:API
    
    var body: some View {
        
        VStack{
            PositionView()
                .cornerRadius(10)
                .shadow(radius: 5)
            StatesView()
                .cornerRadius(10)
                .shadow(radius: 5)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: 400, minHeight: 0, maxHeight: 400)
        .padding()
        
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
        .background(Color.orange.gradient)
    }
}



struct StatesView: View {
    
    @EnvironmentObject var api:API
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Debug Monitor")
                .fontWeight(.semibold)
            
            Spacer()
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
                
                Spacer()
            }
            .font(.system(size: 10))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200)
        .padding()
        .background(Color.orange.gradient)
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




