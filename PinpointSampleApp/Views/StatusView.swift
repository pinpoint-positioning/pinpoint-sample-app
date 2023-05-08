//
//  StatusView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import SDK

struct StatusView: View {
    
    @EnvironmentObject var api:API
    
    var body: some View {
        let address = "Address: \(String(api.status.address))"
        let version = "Version: \(String(api.version.version))"
        let batLvl = "BatteryLevel: \(String(api.status.batteryLevel))"
        let role =  "Role: \(parseRole(byte: api.status.role))"
        let siteID = "Site ID: \(String(api.status.siteIDe))"
        let panID = "Pan ID: \(String(api.status.panID))"
        let batteryState = "BatState: \(parseBatteryState(byte: api.status.batteryState))"
        
        
        VStack(alignment: .leading) {
            Text("Status Monitor")
                .fontWeight(.semibold)
            Divider()
            HStack {
                Text("Connection: ")
                Image(systemName: "circle.fill")
                    .foregroundColor(api.generalState == .CONNECTED ? Color.green : Color.red )
            }
            VStack(alignment: .leading) {
                Text(address)
                Text(version)
                Text(batteryState)
                Text(role)
                Text(panID)
                Text(siteID)
            }
            Spacer()
            
            HStack {
                Spacer()
                Button()
                {
                    api.requestStatus()

                } label:
                {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
        }
        .frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 200)
        .padding()
        .background(Color.orange.gradient)
        .font(.system(size: 10))
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
            .environmentObject(API())
    }
}
