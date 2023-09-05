//
//  LocalStorageManager.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 29.08.23.
//

import Foundation
import SwiftUI

class LocalStorageManager: ObservableObject{
    
    static var shared = LocalStorageManager()
    
    @AppStorage("webdav-server") var webdavServer = ""
    @AppStorage("webdav-user") var webdavUser = ""
    @AppStorage("webdav-pw") var webdavPW = ""
    @AppStorage("remote-positioning") var remotePositioningEnabled = false
    @AppStorage("tracelet-id") var traceletID:String = "\(UUID())"
    @AppStorage("remote-host") var remoteHost = ""
    @AppStorage("remote-port") var remotePort = 8081
    @AppStorage ("channel")  var channel:Int = 5
    @AppStorage ("event-mode")  var eventMode = true
    @AppStorage ("pinpoint-remote-server") var usePinpointRemoteServer = false
}
