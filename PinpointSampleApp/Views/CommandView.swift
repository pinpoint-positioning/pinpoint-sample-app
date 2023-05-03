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
    @State private var showAlert = false
    
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
                
                Button("StartPositioning")
                {
                    api.requestPosition()
                    
                }
                
                Button("StopPositioning")
                {
                    api.stopPositioning()
                }
                
                Button("GetVersion")
                {
                    api.requestVersion()
                }
                
                Button("ShowMe")
                {
                    if let tracelet = api.connectedTracelet {
                        api.showMe(tracelet: tracelet)
                    }
                }
                
                Button("SetInterval")
                {
                    showAlert = true
                    
                }
                .alert("Interval in n x 250ms", isPresented: $showAlert) {
                    TextField("n", text: $interval)
                   

                        Button("Set")
                        {
                            showAlert = false
                            if let interval = Int8(interval) {
                                api.setPositioningInterval(interval: Int8(interval))
                            } else {
                                print("Not an int value")
                            }
                            
                        }
      
                    Button("Cancel", role: .cancel) { }
                }
            }
            
            Spacer()
            
        }
        .frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 200)
        .padding()
        .background(Color.orange.gradient)
        .font(.system(size: 12))
        
    }
    
}


struct CommandView_Previews: PreviewProvider {
    static var previews: some View {
        CommandView()
            .environmentObject(API())
    }
}
