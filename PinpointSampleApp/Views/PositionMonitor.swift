//
//  PositionMonitor.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import Charts
import SDK

struct PositionMonitor: View {
    
    @EnvironmentObject var api:API
    let pos = PositionChartData.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Position Monitor")
                    .fontWeight(.semibold)
                VStack(alignment: .leading) {
                    Text("Current X: \(api.localPosition.xCoord)")
                    Text("Current Y: \(api.localPosition.yCoord)")
                        .onChange(of: api.localPosition, perform: { newValue in
                            pos.fillArray()
                            print (pos.data)
                        })
                }
                
                .font(.system(size: 9))
            }
            
            
            Divider()
            
            Chart(pos.data) {
                
                PointMark(
                    x: .value("X", $0.x),
                    y: .value("Y", $0.y)
                )
                
            }
            .chartYScale(domain: 0...10)
            .chartXScale(domain: 0...10)
            .frame(height: 250)
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 260, maxHeight: 260)
        .padding()
        .background(Color.orange.gradient)
    }
}
    

struct PositionMonitor_Previews: PreviewProvider {
    static var previews: some View {
        PositionMonitor()
            .environmentObject(API())
    }
}
