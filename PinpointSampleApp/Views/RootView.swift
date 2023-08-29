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
    var body: some View {
        
        ZStack{
            Color("pinpoint_background")
            //   .edgesIgnoringSafeArea([.top, .leading , .trailing])
            
            
            PositionViewFullScreen()
        }

     
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            .environmentObject(api)
            .environmentObject(sfm)
            .environmentObject(alerts)
            
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
      
        }
    
    
    struct RootView_Previews: PreviewProvider {
        static var previews: some View {
            RootView()
        }
    }
}
