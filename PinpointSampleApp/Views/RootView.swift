//
//  RootView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 04.08.23.
//
import SwiftUI
import SDK
import AlertToast

struct RootView: View {
    @StateObject var api = API.shared
    @StateObject var sfm = SiteFileManager()
    @StateObject var alerts = AlertController()
    @StateObject var storage = LocalStorageManager()
    var body: some View {
        NavigationStack{
            ZStack{
                FloorMapView()
            }
            
            .onAppear {
                // Set Remote Positioning to false at start
                storage.remotePositioningEnabled = false
            }
            .environmentObject(api)
            .environmentObject(sfm)
            .environmentObject(alerts)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack{
                        Image("pinpoint-circle")
                            .resizable()
                            .frame(width: 30 , height: 30)
                        Text("Pinpoint Positioning")
                            .font(.headline)
                            .foregroundColor(CustomColor.pinpoint_gray)
                    }
                }
            }
             .toolbarBackground(
                Color.orange.opacity(0.9),
                 for: .navigationBar)
             .toolbarBackground(.visible, for: .navigationBar)

            
            // AlertToast
            .toast(isPresenting: $alerts.showNoTraceletInRange){
                AlertToast(type: .regular, title: "No Tracelet in range")
            }
            .toast(isPresenting: $alerts.showConnectedToast){
                AlertToast(type: .complete(.green), title: "Tracelet connected")
            }
            .toast(isPresenting: $alerts.showDisconnectedToast){
                AlertToast(type: .error(.red), title: "Tracelet disconnected")
            }
            .toast(isPresenting: $alerts.showNoWebDavAccount){
                AlertToast(type: .error(.red), title: "No WebDAV configured!")
            }
            .toast(isPresenting: $alerts.showLoading){
                AlertToast(type: .loading, title: "Loading")
            }
            
        }
        
    }
    
    
    struct RootView_Previews: PreviewProvider {
        static var previews: some View {
            RootView()
        }
    }
}
