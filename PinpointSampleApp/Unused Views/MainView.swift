//
//  ContentView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI
import CoreData
import CoreBluetooth
import Charts
import CoreLocation
import MapKit
import FilePicker
import SDK



struct MainView: View {
    
    @State private var showingActions = false




    //MARK: - Body
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center){
                    StatusCircle()
                        .cornerRadius(10)
                        .shadow(radius: 2)                    
                    
                    SiteFileInformationView()
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                
                .padding()
            }
        }
    }

}

//MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(API())
    }
}


//MARK: - Additional views

struct PositionView: View{
    
    @EnvironmentObject var api:API
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Response Monitor")
                .fontWeight(.semibold)
            
            Spacer()
            Divider()
            VStack {
                ConsoleTextView(text: api.allResponses , autoScroll: true)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .background(Color("pinpoint_background"))
        .foregroundColor(Color("pinpoint_gray"))

    }
}



struct StatesView: View {
    
    @EnvironmentObject var api:API
    @State private var logView = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Debug")
                .fontWeight(.semibold)
            
            Divider()
            VStack(alignment: .leading) {
                HStack {
                    Text("Connection: ")
                    Image(systemName: "circle.fill")
                        .foregroundColor(api.generalState == .CONNECTED ? Color.green : Color.red )
                }
                HStack {
                    Text("Device: ")
                    Text(String(describing: api.connectedTracelet?.name ?? ""))
                }
                Divider()
                Text("States")
                    .fontWeight(.semibold)
                HStack {
                    Text("Public: ")
                    Text(String(describing: api.generalState))
                }
                
                HStack {
                    Text("Com: ")
                    Text(String(describing: api.comState))
                }
                HStack {
                    Text("Scan: ")
                    Text(String(describing: api.scanState))
                }
                
                Divider()
                
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
            .font(.system(size: 10))
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .background(Color("pinpoint_background"))
        .foregroundColor(Color("pinpoint_gray"))
        
    }
}

//
//
//
//
//
//struct NavigationBarModifier: ViewModifier {
//        
//    var backgroundColor: UIColor?
//    
//    init( backgroundColor: UIColor?) {
//        self.backgroundColor = backgroundColor
//        let coloredAppearance = UINavigationBarAppearance()
//        coloredAppearance.configureWithTransparentBackground()
//        coloredAppearance.backgroundColor = .clear
//        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        
//        
//        UINavigationBar.appearance().standardAppearance = coloredAppearance
//        UINavigationBar.appearance().compactAppearance = coloredAppearance
//        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
//        UINavigationBar.appearance().tintColor = CustomColor.uiPinpoint_orange
//       
//    }
//    
//    func body(content: Content) -> some View {
//        ZStack{
//            content
//            VStack {
//                GeometryReader { geometry in
//                    Color(self.backgroundColor ?? .clear)
//                        .frame(height: geometry.safeAreaInsets.top)
//                        .edgesIgnoringSafeArea(.top)
//                    Spacer()
//                }
//            }
//        }
//    }
//}
//
//
//extension View {
// 
//    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
//        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
//    }
//
//}





