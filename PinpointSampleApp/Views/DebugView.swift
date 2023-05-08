//
//  SwiftUIView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 08.05.23.
//

import SwiftUI
import SDK

struct DebugView: View{
    
    @EnvironmentObject var api:API
    
    var body: some View {
        
        VStack{
            PositionView()
                .cornerRadius(10)
                .shadow(radius: 5)
            StatesView()
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding()
        
    }
}


struct LogPreview: View{
    
    @EnvironmentObject var api:API
    @State private var logView = false
    
    var body: some View {

        Button("Show Logfile")
        {
            api.openDir()
            logView = true
        }
        .buttonStyle(.bordered)
        .sheet(isPresented: $logView) {
            LogView()
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
        }
    }
}



struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
