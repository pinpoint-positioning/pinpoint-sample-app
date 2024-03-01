//
//  Settings.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 28.08.23.
//

import SwiftUI
import SDK

struct SettingsView: View {
    @Binding var mapSettings: Settings
    @Environment(\.presentationMode) var presentationMode
    
    
    
    @State var updatedTraceletID:String = ""
    
    @EnvironmentObject var api:API
    @EnvironmentObject var sfm : SiteFileManager
    @State var status = TL_StatusResponse()
    @State var version = ""
    @State var interval: Int = 1
    @State private var showIntervalSettings = false
    @State private var showChannelAlert = false
    let logger = Logger.shared
    
    @StateObject var storage = LocalStorageManager.shared
    
    
    var body: some View {
        @State var role = parseRole(byte: Int8(status.role) ?? 0)
        NavigationStack {
            Form {
                Section(header: Text("Settings")) {
                    
                    if api.generalState == .CONNECTED {
                        Button{
                         disconnect()
                        } label: {
                            Text("Disconnect")
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                        }
                    }
                    
                    if !siteFileLoaded() {
                        Text("Load a floor plan to enable options")
                            .foregroundColor(.red)
                    }
                    Stepper(value: $mapSettings.previousPositions, in: 0...10, label: {
                        Text("Previous Positions: \(mapSettings.previousPositions)")
                    })
                    .disabled(!siteFileLoaded())
                    
                    
                    Toggle(isOn: $mapSettings.showRuler) {
                        Text("Show Grid")
                    }
                    .disabled(!siteFileLoaded())
                    
                    Toggle(isOn: $mapSettings.showOrigin) {
                        Text("Show Origin")
                    }
                    .disabled(!siteFileLoaded())
                    
                    Toggle(isOn: $mapSettings.showAccuracyRange) {
                        Text("Show Accuracy")
                    }
                    .disabled(!siteFileLoaded())
                    
                    Toggle(isOn: $mapSettings.showSatlets) {
                        Text("Show Satlets")
                    }
                    .disabled(!siteFileLoaded())
                }
                
                
                
                Section(header: Text("WebDAV Settings")) {
                    HStack {
                        VStack(alignment: .leading){
                            Text("Server")
                                .font(.footnote)
                           
                            TextField("Server-Adress", text: $storage.webdavServer)
                                    .keyboardType(.URL)
                                    .autocapitalization(.none)
                       
                        }
                    }
                    VStack(alignment: .leading){
                        Text("User")
                            .font(.footnote)
                        TextField("Username", text: $storage.webdavUser)
                    }
                    VStack(alignment: .leading){
                        Text("Password")
                            .font(.footnote)
                        TextField("Password", text: $storage.webdavPW)
                    }
                }
                
                
                
                
//                Section(header: Text("Tracelet Info")) {
//                    
//                    ListItem(header: "Adress", subText: $status.address, symbol: "tag.fill")
//                    ListItem(header: "Role", subText: .constant(role), symbol: "person.fill")
//                    ListItem(header: "Version", subText: $version, symbol: "info.circle.fill")
//                    
//                }
                
                
                
//                Section(header: Text("Site Info")) {
//                    
//                    ListItem(header: "PanID", subText: $status.panID, symbol: "square.fill")
//                    ListItem(header: "SiteID", subText: $status.siteIDe, symbol: "square.dashed")
//                    ListItem(header: "Channel", subText: .constant("tbd"), symbol: "dot.radiowaves.left.and.right")
//                    
//                }
//                
                Section(header: Text("Tracelet Settings")) {
                    
                    
                    HStack {
                        Picker("Select a Channel", selection: $storage.channel) {
                            Text("Channel 5").tag(5)
                            Text("Channel 9").tag(9)
                        }
                        .pickerStyle(.automatic)
                        
                        .onChange(of: storage.channel) { newValue in
                            Task {
                                let success = await api.setChannel(channel: Int8(newValue))
                                api.startPositioning()
                            }
                        }
                 
                        
                        Spacer()
                    }
                    
                    Button {
                        Task{
                             await api.setSiteID(siteID: 0x1234)
                        }
                    } label: {
                        Text("Set SiteID")
                    }
                    
                    
//                    HStack {
//                        Picker("Select interval", selection: $interval) {
//                            Text("1 x 250ms").tag(1)
//                            Text("2 x 250ms").tag(2)
//                            Text("3 x 250ms").tag(3)
//                            Text("4 x 250ms").tag(4)
//                            Text("5 x 250ms").tag(5)
//                        }
//                        .pickerStyle(.automatic)
//                        .onChange(of: interval) { newValue in
//                            Task {
//                                print("submit")
//                                print(newValue)
//                                api.setPositioningInterval(interval: Int8(newValue))
//                            }
//                        }
//                        Spacer()
//                    }

                }
                
                
                
                Section(header: Text("Remote Positioning")) {
//                    Link("More information about Remote Positioning", destination: URL(string: "https://pinpoint.de")!)
//                        .font(.footnote)
                    
                    VStack(alignment: .leading){
                        Text("Tracelet Name")
                            .font(.footnote)
                        TextField(UIDevice.current.name, text: $updatedTraceletID)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Remote Host")
                            .font(.footnote)
                        TextField("192.168.0.1", text: $storage.remoteHost)
                            .disabled(storage.usePinpointRemoteServer)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Remote Port")
                            .font(.footnote)
                        TextField("8081", value: $storage.remotePort, formatter: NumberFormatter())
                            .disabled(storage.usePinpointRemoteServer)
                    }
                    
                }
                
                .task {
                    updatedTraceletID = storage.traceletID
                    
                    do {
                        status = try await getStatus()
                        version = await getVersion()
                    } catch {
                        logger.log(type: .Warning, error.localizedDescription)
                    }
                    
                
                }
                
//                Section(header: Text("Debug")) {
//                    NavigationLink {
//                        MainView()
//                    } label: {
//                        Text("More Debug Options")
//                    }
//                    LogPreview()
//                }
                
                Section(header: Text("Contact")) {
                    Link("Visit us at PinPoint.de", destination: URL(string: "https://pinpoint.de")!)
                    Link("Privacy Policy", destination: URL(string: "https://easylocate.gitlab.io/easylocate-mobile-app/")!)
                    
                }
                
                
                
            }
            
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                if !storage.webdavServer.hasPrefix("https://") {
                    storage.webdavServer = "https://" + storage.webdavServer
                }
                storage.traceletID = updatedTraceletID
                presentationMode.wrappedValue.dismiss()
            })
        }
        .presentationDragIndicator(.visible)
    }
    
    
    func siteFileLoaded() -> Bool {
        return sfm.siteFile.map.mapName != ""
    }
    
    
    func getStatus() async throws -> TL_StatusResponse {
        if let status = await api.getStatus() {
            return status
        } else {
            throw CustomError.statusNotFound
        }
    }

    func disconnect() {
        api.disconnect()
    }
    
    func getVersion() async -> String {
        if let version = await api.getVersion() {
            return version
        } else {
            return ""
        }
    }
    
}





struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(mapSettings: .constant(Settings()))
            .environmentObject(API())
    }
}
