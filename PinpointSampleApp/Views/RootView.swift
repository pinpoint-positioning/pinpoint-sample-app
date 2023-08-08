//
//  RootView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 04.08.23.
//
import SwiftUI
import SDK

struct RootView: View {
    @StateObject var api = API.shared
    @StateObject var sfm = SiteFileManager()
    var body: some View {
        
        ZStack{
            Color("pinpoint_background")
             //   .edgesIgnoringSafeArea([.top, .leading , .trailing])
            TabView {

                PositionViewFullScreen()
                    .tabItem {

                        Label("Positioning", systemImage: "map")
                    }
                MainView()
                    .tabItem {

                        Label("Debug", systemImage: "doc.text.magnifyingglass")
                    }
                ConfigView()
                    .tabItem {

                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            .environmentObject(api)
            .environmentObject(sfm)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
