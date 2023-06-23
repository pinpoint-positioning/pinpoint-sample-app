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
    @Binding var siteFile:SiteData?
    @Binding var siteFileName:String
    
    let pos = PositionChartData.shared
    @State private var showAlert = false
    @State var task: Task<Void, Never>? = nil
    @State var test = ""
    @State var xScale = 20.0
    @State var yScale = 20.0
    @Binding var imgH:Int
    @Binding var imgW:Int
    
    // Zoom
    @State private var currentAmount = 0.0
     @State private var finalAmount = 1.0
    


    func setScales (h:Double, w:Double, mapRes:Double) {
        
        DispatchQueue.main.async {
            yScale = (Double(imgH)/mapRes)
            xScale = (Double(imgW)/mapRes)
        }
   
    }
    
    
    
    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                if let siteFile = siteFile {
                    Text("Sitefile: \(siteFile.map.mapFile)")
                        .font(.system(size: 8))
                        .fontWeight(.semibold)
                } else {
                    Text("Sitefile: No sitefile loaded")
                        .font(.system(size: 8))
                }
                Spacer()
                if (siteFile == nil) {
                    Button {
                        showAlert = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.blue)
                        
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

            
            Chart(pos.data) {
                
                PointMark(
                    x: .value("X", $0.x),
                    y: .value("Y", $0.y)
                )
                
            }
            .chartYScale(domain: 0...yScale)
            .chartXScale(domain: 0...xScale)
            .foregroundColor(Color("pinpoint_orange"))
         //   .overlay(siteFile != nil ? floorPlan : nil)
            
            
    //        .onChange(of: api.localPosition, perform: { newValue in
      //          pos.fillArray()
        //    })

            
            .scaleEffect(finalAmount + currentAmount)
            .gesture(
                MagnificationGesture()
                    .onChanged { amount in
                        currentAmount = amount - 1
                    }
                    .onEnded { amount in
                        finalAmount += currentAmount
                        currentAmount = 0
                    }
            )
        

        }

        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight:.infinity)
        .padding()
        .background(Color("pinpoint_background"))
        .foregroundColor(Color("pinpoint_gray"))
        
        
    }
    
 
    
}


//struct PositionMonitor_Previews: PreviewProvider {
//    static var previews: some View {
//        PositionMonitor()
//            .environmentObject(API())
//    }
//}
