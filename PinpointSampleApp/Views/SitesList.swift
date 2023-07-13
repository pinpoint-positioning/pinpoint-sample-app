//
//  SitesList.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 17.05.23.
//

import SwiftUI

import SDK
struct SitesList: View {
    
    @State var list = [String]()
    let sfm = SiteFileManager()
    @State var image:UIImage = UIImage()
    @Binding var siteFile:SiteData?
    @Binding var siteFileName:String
    @State var selection:String?
    @State var isSelected = false
    @State var showImporter = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            List(list, id: \.self, selection: $selection) { item in
                let siteInfo = sfm.loadJson(siteFileName: item)

                Button(action: {
                    if selection == item {
                        selection = nil // Deselect the item
                    } else {
                        selection = item // Set the selected item
                    }

                    if let siteFile = sfm.loadJson(siteFileName: item) {
                        self.siteFile = siteFile
                        self.siteFileName = item
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item)
                                .fontWeight((siteFileName == item) ? .bold : .regular)
                                .font(.system(size: 16))
                            
                            Text("Resolution: \(siteInfo?.map.mapFileRes ?? 0)")
                                .font(.system(size: 10))
                            
                            Text("Site ID: \(siteInfo?.map.mapSiteId ?? "unknown")")
                                .font(.system(size: 10))
                            
                            Text("UWB-Channel: \(siteInfo?.map.uwbChannel ?? 0)")
                                .font(.system(size: 10))
                        }
                        
                        Spacer()
                        
                        Image(systemName: siteFileName == item ? "circle.fill" : "circle")
                            .foregroundColor(siteFileName == item ? .orange : .gray)
                            .font(.system(size: 24))
                            .overlay(
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 24))
                                    .opacity(siteFileName == item ? 1 : 0)
                            )
                    }
                }
                .foregroundColor(selection == item ? .blue : .black) // Change the text color based on selection
            }




            .task {
                list = sfm.getSitefilesList()
                
            }
            
            Spacer()
            Button(action: {
                 clearCache()
             }) {
                 Text("Delete all SiteFiles")
                     .foregroundColor(.white)
                     .font(.headline)
                     .padding()
                     .background(Color.red)
                     .cornerRadius(10)
             }
             .padding()
        }
        .navigationTitle("Import SiteFile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                
                // Import SiteFile
                Button() {
                    showImporter = true
                } label: {
                    Image(systemName: "folder")
                }
                
                // webdav test
               
                NavigationLink{
                    RemoteSitesList()
                }
                 label: {
                    Image(systemName: "cloud")
                }
                
                
            }

            
            
        }
        
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.zip],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                
                guard selectedFile.startAccessingSecurityScopedResource() else {
                    // Handle the failure here.
                    return
                }
                
                let documentsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let destinationUrl = documentsUrl.appendingPathComponent(selectedFile.lastPathComponent)
                
                if let dataFromURL = NSData(contentsOf: selectedFile) {
                    if dataFromURL.write(to: destinationUrl, atomically: true) {
                        let sfm = SiteFileManager()
                        
                        Task {
                           _ =  await sfm.unarchiveFile(sourceFile: destinationUrl)
                            list = sfm.getSitefilesList()
                        }
                        
                        if let sfContent = sfm.loadJson(siteFileName: "sitedata.json") {
                            siteFile = sfContent
                        }
                    } else {
                        print("error saving file")
                        let error = NSError(domain: "Error saving file", code: 1001, userInfo: nil)
                        print(error)
                    }
                }
                
                selectedFile.stopAccessingSecurityScopedResource()
            } catch {
                print(error)
            }
        }

        
        

        
        
    }

    
    func clearCache(){
        let fileManager = FileManager.default
        do {
            let documentDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for url in fileURLs {
                try fileManager.removeItem(at: url)
                list.removeAll()
            }
        } catch {
            print(error)
        }
    }
}







