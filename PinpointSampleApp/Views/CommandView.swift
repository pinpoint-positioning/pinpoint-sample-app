//
//  CommandView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import SDK

struct CommandView: View {
    @State var interval = ""
    @State private var showIntervalSettings = false
    @State private var showResponseAlert = false
    @State private var showChannelAlert = false
    @State private var version = ""
    @State private var channel:Int8 = 5


    @EnvironmentObject var api:API
    
    
    var body: some View {

            HStack (alignment: .top,  spacing: 50) {
                
                Button()
                {
                    api.requestPosition()
                    
                } label: {
                    VStack {
                        Image(systemName: "play.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Start")
                    }
                }
                
                Button()
                {
                    api.stopPositioning()
                }  label: {
                    VStack {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Stop")
                    }
                }
                
             
                Button()
                {
                    if let tracelet = api.connectedTracelet {
                        api.showMe(tracelet: tracelet)
                    }
                } label: {
                    VStack {
                        Image(systemName: "eye.fill")
                            .resizable()
                            .frame(width: 20, height: 15)
                        Text("Show")
                    }
                }
                
                
      
            }
        .foregroundColor(Color("pinpoint_gray"))
        .font(.system(size: 12))
 
    }
    
}


struct CommandView_Previews: PreviewProvider {
    static var previews: some View {
        CommandView()
            .environmentObject(API())
    }
}
