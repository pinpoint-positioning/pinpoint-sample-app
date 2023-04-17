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
    
    @State var scanButtonLabel = ""
    @State private var showingActions = false
    @State private var consoleHeight = 600.0
    @EnvironmentObject var api:API
    
    //MARK: - Body
    var body: some View {
        
        ZStack{
            VStack(alignment: .leading){
                //Header
                Header()
                
                // Console Output
                ConsoleTextView(text: api.allResponses , autoScroll: true)
                    .frame(height: consoleHeight)
                    .opacity(0.7)
                
                //Buttons
                HStack {
                    CommandButtons()
                    Button
                    {
                        showingActions.toggle()
                    } label: {
                        HStack {
                            Text("Actions")
                            Image(systemName: "chevron.up")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            // Actions menu
            .sheet(isPresented: $showingActions) {
                ActionsView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}


//MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
            .buttonStyle(.borderedProminent)
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
            .buttonStyle(.borderedProminent)
            .disabled(api.generalState == .CONNECTED ? false : true)
            Spacer()
        }
        .padding()
    }
}



struct ActionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api:API
    @State var showingResponse = false
    @State var response = ""
    
    var body: some View {
        NavigationStack{
            let state = "State: \(api.generalState)"
            Text(state)
            List
            {
                Button("GetStatus")
                {
                    api.getStatusString { statusString in
                        response = statusString
                        showingResponse.toggle()
                    }
                    dismiss()
                }
                
                .sheet(isPresented: $showingResponse) {
                    ResponseView(response:  response)
                        .presentationDetents([.medium])
                }
                Button("GetPosition")
                {
                    api.getOneTimePostion { position in
                        response = """
                                                            X: \(position.xCoord) \n \
                                                            Y: \(position.yCoord) \n \
                                                            Z: \(position.zCoord)
                                                            """
                        showingResponse.toggle()
                    }
                    dismiss()
                }
                
                .sheet(isPresented: $showingResponse) {
                    ResponseView(response:  response)
                        .presentationDetents([.medium])
                }
                
                Button("GetVersion")
                {
                    api.requestVersion { version in
                        response = version
                        showingResponse.toggle()
                    }
                    dismiss()
                }
                .sheet(isPresented: $showingResponse) {
                    ResponseView(response: response)
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
                
                Text("Tracelet Reader")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
            HStack {
                Text("Connection state: ")
                Image(systemName: "circle.fill")
                    .foregroundColor(api.generalState == .CONNECTED ? Color.green : Color.red )
                Spacer()
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



// unsused

struct ResponseView: View {
    
    @Environment(\.presentationMode) var presentationMode
    let response: String
    
    var body: some View {
        
        List{
            Text(response)
        }
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
