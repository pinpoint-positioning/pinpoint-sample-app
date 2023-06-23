//
//  RemoteSitesList.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 23.06.23.
//

import SwiftUI

struct RemoteSitesList: View {
    @State private var sites = [String]()
    @State private var selectedSite: String?
    var body: some View {
        
        VStack{
            
            List(sites, id: \.self) { site in
                
                NavigationLink(site) {
                    FileDownloadView(site: site)
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
            downloadFile(site)
        }

    }
    
    
    func downloadFile(_ site: String) {
        guard let url = URL(string: "https://connect.pinpoint.de\(site)" ) else {
            print("Invalid file URL")
            return
        }
        
        // Create a session configuration with the appropriate credentials
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Basic " + "\("PinPoint_Debug"):\("123undlos!!!")".data(using: .utf8)!.base64EncodedString()]
        
        // Create a session with the configuration
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading file: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    fileData = data
                }
            } else {
                print("No file data received")
            }
        }
        task.resume()
    }
}


struct RemoteSitesList_Previews: PreviewProvider {
    static var previews: some View {
        RemoteSitesList()
    }
}
