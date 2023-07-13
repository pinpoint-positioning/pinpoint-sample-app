//
//  StatusCircle.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 16.06.23.
//

//
//  PositionMonitor.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import Charts
import SDK

struct StatusCircle: View {
    
    @EnvironmentObject var api:API
    
    var body: some View {
        
        ZStack(alignment: .top){

            Circle()
                .foregroundColor(Color("pinpoint_orange"))
                .frame(width: 300, height: 300)
            VStack(spacing: 15){
                Image("pinpoint-circle")
                    .resizable()
                    .frame(width: 100, height: 100)

                    Text(api.generalState == .CONNECTED ? "Connected" : "Disconnected")
                        .fontWeight(.bold)
                    Text(api.deviceName)
                
                HStack(spacing: 50){
                    HStack{
                        Image(systemName: "x.circle")
                        Text(String(api.localPosition.xCoord))
                    }
                    
                    HStack{
                        Image(systemName: "y.circle")
                        Text(String(api.localPosition.yCoord))
                    }
                }
               
                CommandView()
                
                Spacer()
                
            }
            
        }
        .padding(.all)
        
        
        
    }
}




struct StatusCircle_Previews: PreviewProvider {
    static var previews: some View {
        StatusCircle()
            .environmentObject(API())
    }
}
