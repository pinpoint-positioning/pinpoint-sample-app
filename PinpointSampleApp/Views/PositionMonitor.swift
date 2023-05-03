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
    @EnvironmentObject var wgs84:Wgs84Reference
    
    let pos = PositionChartData.shared
    @State private var showAlert = false
    @State var task: Task<Void, Never>? = nil
    @State var test = ""
    @State var xScale = 20
    @State var yScale = 20
    
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Position Monitor")
                    .onTapGesture {
                        task = Task {
                            
                            let loc = AsyncLocationStream.shared
                            
                            for await location in loc.stream {
                                print ("hier")
                                print(location.xCoord)
                            }
                        }
                    }
                
                    .fontWeight(.semibold)
                
                HStack {
                    VStack(alignment: .leading) {
                        
                        Text( String(format: "Current X: %.1f", api.localPosition.xCoord))
                        Text( String(format: "Current Y: %.1f", api.localPosition.yCoord))
                            .onTapGesture {
                                task?.cancel()
                                
                            }
                        
                            .onChange(of: api.localPosition, perform: { newValue in
                                pos.fillArray()
                            })
                    }
                    
                    .font(.system(size: 9))
                    Spacer()
                    Button {
                        showAlert = true
                    } label: {
                        Image(systemName: "gear")
                        
                    }
                    .alert("Graph settings", isPresented: $showAlert) {
                        
      
                            TextField("X-scale: \(xScale)", value: $xScale, format: .number)
                
                  
                        
                        TextField("Y-scale: \(yScale)", value: $yScale, format: .number)
                        
                        
                        Button("OK", action: {})
                        
                    } message: {
                        Text("Set X / Y scale of graph")
                    }
                    
                }
            }
            
            
            
            Divider()
            
            Chart(pos.data) {
                
                PointMark(
                    x: .value("X", $0.x),
                    y: .value("Y", $0.y)
                )
                
            }
            .chartYScale(domain: 0...yScale)
            .chartXScale(domain: 0...xScale)
            .frame(height: 250)
            //            .overlay {
            //                Image("roomplan")
            //                    .resizable()
            //                    .opacity(0.5)
            //
            //
            //            }
            
        }
        .frame(minWidth: 0, maxWidth: 400, minHeight: 260, maxHeight: 260)
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
