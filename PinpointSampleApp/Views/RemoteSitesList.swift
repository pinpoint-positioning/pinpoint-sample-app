//
//  RemoteSitesList.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 23.06.23.
//

import SwiftUI
import SDK
import WebDAV

struct RemoteSitesList: View {
    @State private var sites = [String]()
    @State private var selectedSite: String?
    var body: some View {
        
        VStack{
            
            List(sites, id: \.self) { site in
                
                Button(site) {
                    download(site: site)
                }
  
            }
        }
        .onAppear() {
            Task{
                sites = await NextcloudFileLister().listFilesInNextcloudFolder()
                print (sites)
            }
        }

        
    }
}

struct Account:WebDAVAccount {
    var username: String?
    
    var baseURL: String?

}

func download(site:String) {
    
    let wd = WebDAV()
    let account = Account(username: "PinPoint_Debug", baseURL: "https://connect.pinpoint.de")
    wd.download(fileAtPath:"/remote.php/dav/files/PinPoint_Debug\(site)", account: account, password: "123undlos!!!") { data, error in
        print (data)
        if let error = error {
            print (error)
        }
    }

}



struct FileDownloadView: View {
    let site: String

    @State private var fileData: Data?
    
    var body: some View {
        VStack {
            if let data = fileData {
                // Display the downloaded file content
                Text(String(data: data, encoding: .utf8) ?? "Failed to read file data")
            } else {
                // Show loading indicator or any other UI while downloading
                ProgressView()
            }
        }
        .onAppear {
            
        }

    }

}


struct RemoteSitesList_Previews: PreviewProvider {
    static var previews: some View {
        RemoteSitesList()
    }
}
