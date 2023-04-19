//
//  CommandView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import SDK

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
            }
            
            Spacer()
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200)
        .padding()
        .background(Color.orange.gradient)
        
    }
    
}


struct CommandView_Previews: PreviewProvider {
    static var previews: some View {
        CommandView()
            .environmentObject(API())
    }
}
