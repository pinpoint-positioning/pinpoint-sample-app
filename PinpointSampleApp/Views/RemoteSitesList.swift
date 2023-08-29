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
    @EnvironmentObject var sfm:SiteFileManager
    @EnvironmentObject var alerts : AlertController
    @State private var sites = [String]()
    @State private var selectedSite: String?
    @State private var isDownloadSuccessful = true
    @Environment(\.dismiss) var dismiss

    
    
    var body: some View {
        NavigationStack {
            ZStack{
                List(sites, id: \.self) { site in
                    if let url = URL(string: site) {
                        Button(url.lastPathComponent) { // Use lastPathComponent as the label
                            Task {
                                isDownloadSuccessful = false
                                isDownloadSuccessful = await sfm.downloadAndSave(site: site)
                                dismiss()
                            }
                        }
                    } else {
                        Text("Invalid URL: \(site)")
                    }
                }

     
                .onAppear() {
                    Task{
                        if let foundSites = await NextcloudFileLister().listFilesInNextcloudFolder() {
                            sites = foundSites
                        } else {
                            print("nothing found")
                        }
                        
                    }
                }
                
                if !isDownloadSuccessful {
                    Color.gray
                        .opacity(0.5)
                    ProgressView()
                    
                }
            }
            .navigationTitle("Download Site")
            .navigationBarTitleDisplayMode(.inline)

        }
    }

}

struct Account:WebDAVAccount {
    var username: String?
    
    var baseURL: String?

}

        
      

        struct RemoteSitesList_Previews: PreviewProvider {
            static var previews: some View {
                RemoteSitesList()
            }
        }
    
