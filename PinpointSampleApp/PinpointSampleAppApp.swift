//
//  PinpointSampleAppApp.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI
import SDK

@main
struct PinpointSampleAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            //TestView()
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
              
        }
    }
}
