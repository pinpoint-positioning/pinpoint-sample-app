//
//  ExpandablePanel.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 30.08.23.
//

import SwiftUI
import SDK


struct ExpandablePanel: View {
    
    @EnvironmentObject var api : API
    @EnvironmentObject var sfm : SiteFileManager
    @EnvironmentObject var alerts : AlertController
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation(.linear) {
                    self.isExpanded.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    Text("More info").font(.caption)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                  
                }
                .background(.ultraThinMaterial)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            
            if isExpanded {
                
                VStack(alignment:.leading, spacing: 5) {
                    Text("Tracelet: \(api.connectedTracelet?.name ?? "")")
                        .font(.caption)
                    
                    Text("Channel: \(sfm.siteFile.map.uwbChannel)")
                        .font(.caption)
                    
                    HStack {
                        Text("Position:")
                            .font(.caption)

                            Text("X: \(String(format: "%.1f", api.localPosition.xCoord))")
                                .font(.caption)
                            Text("Y: \(String(format: "%.1f", api.localPosition.yCoord))")
                                .font(.caption)
                 
                    }
                    
                    Text("SiteID: \(sfm.siteFile.map.mapSiteId)")
                        .font(.caption)
                }
                .padding(EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3))
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
            }
        }
        .padding(3)
    }
}


struct ExpandablePanel_Previews: PreviewProvider {
    static var previews: some View {
        ExpandablePanel()
    }
}
