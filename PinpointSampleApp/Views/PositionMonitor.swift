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

    func setScales (h:Double, w:Double, mapRes:Double) {
        
        DispatchQueue.main.async {
            yScale = (Double(imgH)/mapRes)
            xScale = (Double(imgW)/mapRes)
            print ("imgh \(imgH) imgw \(imgW)")
            print ("scales x \(xScale), y \(yScale)")
        }
   
    }
    
    
    
    var body: some View {
        
        let floorPlan = 
            
            GeometryReader { geo in
                
                Image(uiImage:SiteFileManager().getFloorImage(siteFileName: siteFileName) ?? UIImage())
                    .resizable()
                    .opacity(0.5)
                
                let _ = print (geo.size)
                let _ = setScales(h: geo.size.height, w: geo.size.width, mapRes: 39.0)
                let _ = print (Int(geo.size.height),Int(geo.size.width) )
            }
        
        
        

        
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
            .frame(height: 250)
            .foregroundColor(Color("pinpoint_orange"))
            .overlay(siteFile != nil ? floorPlan : nil)
            
            
            .onChange(of: api.localPosition, perform: { newValue in
                pos.fillArray()
            })

        }

        .frame(minWidth: 0, maxWidth: 400, minHeight: 260, maxHeight: 260)
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
