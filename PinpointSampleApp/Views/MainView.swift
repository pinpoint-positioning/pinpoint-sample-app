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
        @State var showImporter = false
        @State var siteFile:SiteFile?
        
        //MARK: - Body
        var body: some View {
            
         
            NavigationStack{
                ZStack{
                    Color("pinpoint_background")
                    
                        .ignoresSafeArea()
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading){
                                
                                PositionMonitor(siteFile: $siteFile)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                
                                HStack{
                                    StatusView()
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                        .blur(radius: api.generalState != .CONNECTED ? 1 : 0)
                                        .overlay(api.generalState != .CONNECTED ? Text("Not connected")
                                            .fontWeight(.semibold): nil)
                                    
                                        .disabled(api.generalState != .CONNECTED ? true : false )
                                    
                                    CommandView()
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                        .blur(radius: api.generalState != .CONNECTED ? 1 : 0)
                                        .overlay(api.generalState != .CONNECTED ? Text("Not connected")
                                            .fontWeight(.semibold): nil)
                                        .disabled(api.generalState != .CONNECTED ? true : false)
                                    
                                }
                                Spacer()
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
                            NavigationLink("Debug", destination:  DebugView())
            
                        }
                        
                        
                        ToolbarItemGroup(placement: .secondaryAction) {
                            
                            
                            Button("Import SiteFile (still buggy)") {
                                showImporter = true
                            }
                            
                            if let siteFile = siteFile {
                                let place = IdentifiablePlace(lat: siteFile.map.originLatitude, long: siteFile.map.originLongitude)
                                NavigationLink("Map", destination:  MapView(siteFile: siteFile, place: place))
                            }
                            
                           
                            Button("Clear all sitefiles") {
                                clearCache()
                            }
          
                        }
                    }
                    
                    .fileImporter(
                        isPresented: $showImporter,
                        allowedContentTypes: [.zip],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            
                            guard selectedFile.startAccessingSecurityScopedResource() else {
                                // Handle the failure here.
                                return
                            }
                            
                            let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                            let destinationUrl = documentsUrl.appendingPathComponent(selectedFile.lastPathComponent)
                            
                            if let dataFromURL = NSData(contentsOf: selectedFile) {
                                if dataFromURL.write(to: destinationUrl, atomically: true) {
                                    print("file saved [\(destinationUrl.path)]")
                                    //print (try String(contentsOf: destinationUrl))
                                    let sfm = SiteFileManager()
                                    sfm.processSiteFile(sourceFile: destinationUrl)
                                    if let sfContent = sfm.loadJson(filename: "data.json") {
                                        siteFile = sfContent
                                        print (siteFile)
                                    }
                                    
                                    
                                    
                                } else {
                                    print("error saving file")
                                    let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                    print(error)
                                }
                            }
                            
                            selectedFile.stopAccessingSecurityScopedResource()
                            
                        } catch {
                            print(error)
                        }
                        
                    }
                    
                }
                
            }
            .environmentObject(API.shared)
            .environmentObject(Wgs84Reference.shared)
        }
        
        
        func clearCache(){
            let fileManager = FileManager.default
            do {
                let documentDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                for url in fileURLs {
                   try fileManager.removeItem(at: url)
                }
            } catch {
                print(error)
            }
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
    
    
    
    
