//
//  StatusView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import SDK

struct SiteFileInformationView: View {
    
    @EnvironmentObject var api:API
    @State var status = TL_StatusResponse()
    @Binding var siteFile:SiteData?
    let symbolScale = 30.0
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            Text("SiteFile Information")
                .fontWeight(.semibold)
            Divider()
            
            
            
            if let siteFile = siteFile {
                HStack(alignment: .top){
                    
                    // Left side
                    VStack(alignment: .leading){
                        
                        
                        HStack{
                            Image(systemName: "tag.fill")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Map name")
                                    .fontWeight(.semibold)
                                Text(siteFile.map.mapName)
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        
                        HStack{
                            Image(systemName: "ruler")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Map resolution")
                                    .fontWeight(.semibold)
                                Text(String(siteFile.map.mapFileRes))
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        
                        HStack{
                            Image(systemName: "square.dashed")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Site ID")
                                    .fontWeight(.semibold)
                                Text(String(siteFile.map.mapSiteId))
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        
                        HStack{
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Channel")
                                    .fontWeight(.semibold)
                                Text(String(siteFile.map.uwbChannel))
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
                    
                    }
                    
                    Divider()
                    
                    // Right side
                    VStack(alignment: .leading){

                        
                        HStack{
                            Image(systemName: "tag")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Mapfile")
                                    .fontWeight(.semibold)
                                Text(String(siteFile.map.mapFile))
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
   
                        HStack{
                            Image(systemName: "location")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Origin Azimuth")
                                    .fontWeight(.semibold)
                                Text(String(siteFile.map.originAzimuth))
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        
                        HStack{
                            Image(systemName: "location.north")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Origin Latitude")
                                    .fontWeight(.semibold)
                                Text(String(siteFile.map.originLatitude))
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        
                        HStack{
                            Image(systemName: "location.circle")
                                .frame(width: symbolScale, height: symbolScale)
                            VStack(alignment: .leading) {
                                
                                Text("Origin Longitude")
                                    .fontWeight(.semibold)
                                Text(String(siteFile.map.originLongitude))
                                    .fontWeight(.regular)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                    
                    
                    
                }
            } else {
                Text("No SiteFile loaded")
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .background(Color("pinpoint_background"))
        .foregroundColor(Color("pinpoint_gray"))
        .font(.system(size: 10))
        
        
        
        
        
        
    }
}

//struct StatusView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusView()
//            .environmentObject(API())
//    }
//}
