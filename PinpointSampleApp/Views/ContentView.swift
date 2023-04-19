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


struct MainView: View {
    
    var body: some View {
        TabView{
            ContentView()
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            
            DebugView()
                .tabItem {
                    Label("Debug", systemImage: "ladybug.fill")
                }
            
        }
    }
}



struct ContentView: View {
    
    @State var scanButtonLabel = ""
    @State private var showingActions = false
    @EnvironmentObject var api:API
    
    //MARK: - Body
    var body: some View {

            ZStack{
                VStack {
                    Header()
                    ScrollView {
                        VStack(alignment: .leading){

                            HStack {
                                PositionChartView()
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            
                            HStack{
                                StatusView()
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                
                                CommandView()
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            Spacer()

                        }
                        
                    }
                    
                    //Buttons
                    HStack {
                        
                        CommandButtons()
                        Button
                        {
                            showingActions.toggle()
                        } label: {
                            HStack {
                                Text("Cmds")
                                Image(systemName: "chevron.up")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)

                }
            }
            .padding()
            // Actions menu
            .sheet(isPresented: $showingActions) {
                ActionsModalView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
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
    @State var notify = false
    @State private var showingScanResults = false
    
    var body: some View {
        HStack {
            Button (api.scanState == .SCANNING ? "Stop" : "Scan")
            {
                if (api.scanState == .SCANNING)
                {
                    api.stopScan()
                } else {
                    showingScanResults.toggle()
                    api.scan(timeout: 2.0)
                }
                
            }
            .buttonStyle(.bordered)
            .disabled(api.generalState == .CONNECTED)
            
            // ScanList menu
            .sheet(isPresented: $showingScanResults) {
                DeviceListView()
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
                
                
                Button("GetPosition")
                {
                    Task {
                        api.requestPosition()
                    }
                }
                
                Button("GetVersion")
                {
                    dismiss()
                }
                
                
                
                Button("StopPosition")
                {
                    api.stopPositioning()
                    dismiss()
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



struct DebugView: View{
    
    @EnvironmentObject var api:API
    
    var body: some View {
        
        HStack{
            
            PositionView()
                .cornerRadius(10)
                .shadow(radius: 5)
            StatesView()
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding()
     
    }
}




struct PositionView: View{
    
    @EnvironmentObject var api:API
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Position Monitor")
                .fontWeight(.semibold)

            Spacer()
            Divider()
            VStack {
                ConsoleTextView(text: api.allResponses , autoScroll: true)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200)
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



struct StatusView: View {
    
    @EnvironmentObject var api:API
    
    var body: some View {
        let address = "Address: \(String(api.status.address))"
        let version = "Version: \(String(api.version.version))"
        let batLvl = "BatteryLevel: \(String(api.status.batteryLevel))"
        let role = "Role: \(String(api.status.role))"
        let siteID = "Site ID: \(String(api.status.siteIDe))"
        let panID = "Pan ID: \(String(api.status.panID))"
        
        
        VStack(alignment: .leading) {
            Text("Status Monitor")
                .fontWeight(.semibold)
            Divider()
            Text(address)
            Text(version)
            Text(batLvl)
            Text(role)
            Text(panID)
            Text(siteID)
            Spacer()
            
            HStack {
                Spacer()
                Button()
                {
                    api.requestStatus()
                    api.requestVersion()
                } label:
                {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200)
        .padding()
        .background(Color.orange.gradient)
    }
}


struct CommandView: View {
    
    @EnvironmentObject var api:API
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Commands")
                .fontWeight(.semibold)
            Divider()
            
            VStack (alignment: .leading,  spacing: 6) {
                Button("GetStatus")
                {
                    api.requestStatus()
                   }
                
                
                Button("GetPosition")
                {
                    api.requestPosition()

                }
                
                Button("GetVersion")
                {
                    api.requestVersion()
                }
                

                Button("StopPosition")
                {
                    api.stopPositioning()
                }
                
                Button("ShowMe")
                {
                    if let tracelet = api.connectedTracelet {
                        api.showMe(tracelet: tracelet)
                    }
                }
            }
            
            Spacer()

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
    
    var body: some View {
        
        List{
            ForEach(api.discoveredTracelets, id: \.self) { device in
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



struct PositionChartView: View {
   
    @EnvironmentObject var api:API
    let pos = PositionChartData.shared

    var body: some View {
   
        VStack(alignment: .leading) {
            HStack {
                Text("Position Monitor")
                    .fontWeight(.semibold)
                VStack(alignment: .leading) {
                    Text("Current X: \(api.localPosition.xCoord)")
                    Text("Current Y: \(api.localPosition.yCoord)")
                        .onChange(of: api.localPosition, perform: { newValue in
                            pos.fillArray()
                            print (pos.data)
                        })
             
                            
                        }

                        
                .font(.system(size: 9))
            }

               
            Divider()

            Chart(pos.data) {


                    PointMark(
                        x: .value("X", $0.x),
                        y: .value("Y", $0.y)
                    )

                }
                .chartYScale(domain: 0...10)
                .chartXScale(domain: 0...10)
                .frame(height: 250)

        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 260, maxHeight: 260)
        .padding()
        .background(Color.orange.gradient)
    }
}
