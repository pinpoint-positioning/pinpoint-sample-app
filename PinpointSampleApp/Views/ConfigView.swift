//
//  ConfigView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 17.05.23.
//

import SwiftUI
import SDK

struct ConfigView: View {
    
    @EnvironmentObject var api:API
    @State var status = TL_StatusResponse()
    @State var version = ""
    @State var interval = ""
    @State private var showIntervalSettings = false
    @State private var showChannelAlert = false
    @State private var channel:Int8 = 0
   
    var body: some View {
      @State var role = parseRole(byte: Int8(status.role) ?? 0)
        NavigationStack{
            VStack {
                
                List {
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
                        Button("Set channel 9")
                        {
                            channel = 9
                            Task {
                                showChannelAlert = await api.setChannel(channel: channel)
                            }
                            
                        }
                        
                        
                        Button("Set channel 5")
                        {
                            channel = 5
                            Task {
                                showChannelAlert = await api.setChannel(channel: channel)
                            }
                        }
                        .alert("Set channel", isPresented: $showChannelAlert) {}
                    message: {
                        Text("Channel set to \(channel)")
                    }
                        
                        
                        
                        
                        Button("Set interval")
                        {
                            showIntervalSettings = true
                            
                        }
                        .alert("Interval in n x 250ms", isPresented: $showIntervalSettings) {
                            TextField("n", text: $interval)
                            Button("Set")
                            {
                                showIntervalSettings = false
                                if let interval = Int8(interval) {
                                    api.setPositioningInterval(interval: Int8(interval))
                                } else {
                                    print("Not an int value")
                                }
                                
                            }
                            
                            Button("Cancel", role: .cancel) { }
                        }
                    }
                    
                }
                .scrollDisabled(true)
            }
            .task {
                if let status = await api.getStatus() {
                    self.status = status
                }
                
                if let version = await api.getVersion() {
                    self.version = version
                }
            }
            
 

        }
        .navigationTitle("Tracelet Configuration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                
                Button() {
                    Task {
                        
                        if let status = await api.getStatus() {
                            self.status = status
                        }
                        
                        if let version = await api.getVersion() {
                            self.version = version
                        }
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
        }
                
    }
}



struct ListItem: View {
    
    @State var header:String
    @Binding var subText:String
    @State var symbol:String

    var body: some View {
        
        HStack{
            Image(systemName: symbol)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                
                Text(header)
                    .fontWeight(.semibold)
                Text(subText)
                    .fontWeight(.regular)
                    .font(.system(size: 12))
            }
        }
    }
}


struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView()
    }
}
