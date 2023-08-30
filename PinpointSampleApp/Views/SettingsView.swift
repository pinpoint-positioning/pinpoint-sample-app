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


    
    @State var updatedTraceletID = ""
   
    @EnvironmentObject var api:API
    @State var status = TL_StatusResponse()
    @State var version = ""
    @State var interval: Int = 1
    @State private var showIntervalSettings = false
    @State private var showChannelAlert = false
    @State private var showAlert = false
    @StateObject var storage = LocalStorageManager()


    var body: some View {
        @State var role = parseRole(byte: Int8(status.role) ?? 0)
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    Stepper(value: $mapSettings.previousPositions, in: 0...10, label: {
                        Text("Previous Positions: \(mapSettings.previousPositions)")
                    })
                    
                    Toggle(isOn: $mapSettings.showRuler) {
                        Text("Show Ruler")
                    }
                    
                    Toggle(isOn: $mapSettings.showOrigin) {
                        Text("Show Origin")
                    }
                    
                    Toggle(isOn: $mapSettings.showAccuracyRange) {
                        Text("Show Accuracy")
                    }
                    Toggle(isOn: $mapSettings.showSatlets) {
                        Text("Show Satlets")
                    }
                }
     
                Section(header: Text("Remote Positioning")) {
                    
//                    Toggle(isOn: $remotePositioningEnabled) {
//                                   Text("Allow Remote Positioning")
//                               }
//                               .onChange(of: remotePositioningEnabled) { newValue in
//                                   // Show the alert when the toggle is switched on
//                                   if newValue {
//                                       showAlert = true
//                                   }
//                               }
//                               .alert(isPresented: $showAlert) {
//                                   Alert(
//                                       title: Text("Are you sure?"),
//                                       message: Text("You will share your position remotely!"),
//                                       primaryButton: .default(Text("Yes")) {
//                                           // Set the state to on when confirmed
//                                           remotePositioningEnabled = true
//                                       },
//                                       secondaryButton: .cancel(Text("No")) {
//                                           // Set the state to off if canceled
//                                           remotePositioningEnabled = false
//                                       }
//                                   )
//                               }
                           

                   
                    VStack(alignment: .leading){
                        Text("Tracelet Name")
                            .font(.footnote)
                        TextField("Tracelet Name", text: $updatedTraceletID)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Remote Host")
                            .font(.footnote)
                        TextField("Remote Host", text: $storage.remoteHost)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Remote Port")
                            .font(.footnote)
                        TextField("Remote Port", value: $storage.remotePort, formatter: NumberFormatter())
                    }
                    
                }
                
                .task {
                    updatedTraceletID = storage.traceletID
                }
                
                Section(header: Text("Tracelet Info")) {

                        ListItem(header: "Adress", subText: $status.address, symbol: "tag.fill")
                    ListItem(header: "Role", subText: .constant(role), symbol: "person.fill")
                        ListItem(header: "Version", subText: $version, symbol: "info.circle.fill")
   
                }
                


                Section(header: Text("Site Info")) {
                    
                    ListItem(header: "PanID", subText: $status.panID, symbol: "square.fill")
                    ListItem(header: "SiteID", subText: $status.siteIDe, symbol: "square.dashed")
                    ListItem(header: "Channel", subText: .constant("tbd"), symbol: "dot.radiowaves.left.and.right")
                    
                }
                
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

                    
                    
                    HStack {
                        Picker("Select interval", selection: $interval) {
                            Text("1 x 250ms").tag(1)
                            Text("2 x 250ms").tag(2)
                            Text("3 x 250ms").tag(3)
                            Text("4 x 250ms").tag(4)
                            Text("5 x 250ms").tag(5)
                        }
                        .pickerStyle(.automatic)
                        .onChange(of: interval) { newValue in
                            Task {
                                print("submit")
                                print(newValue)
                                 api.setPositioningInterval(interval: Int8(newValue))
                            }
                        }
                            Spacer()
                    }
                    
                    LogPreview()
                    NavigationLink {
                        MainView()
                    } label: {
                        Text("More Debug Options")
                    }
       

                    }
                
                Section(header: Text("Contact")) {
                    Link("Visit us at PinPoint.de", destination: URL(string: "https://pinpoint.de")!)
                    Link("Privacy Policy", destination: URL(string: "https://easylocate.gitlab.io/easylocate-mobile-app/")!)

                }
                
                
                
                    Section(header: Text("WebDAV Settings")) {
                        VStack(alignment: .leading){
                            Text("Server")
                                .font(.footnote)
                            TextField("Server", text: $storage.webdavServer)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
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
                }
            
            .navigationTitle("Map Settings")
            .navigationBarItems(trailing: Button("Done") {
                storage.traceletID = updatedTraceletID
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(mapSettings: .constant(Settings()))
    }
}
