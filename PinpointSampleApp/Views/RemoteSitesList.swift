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
    @State private var sites = [String]()
    @State private var selectedSite: String?
    @State private var isDownloadSuccessful = true
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationStack {
            ZStack{
                List(sites, id: \.self) { site in
                    
                    Button(site) {
                        Task {
                            isDownloadSuccessful = false
                            isDownloadSuccessful = await sfm.downloadAndSave(site: site)
                            dismiss()
                        }
                    }
                    
                }
                .onAppear() {
                    Task{
                        sites = await NextcloudFileLister().listFilesInNextcloudFolder()
                        
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
    
