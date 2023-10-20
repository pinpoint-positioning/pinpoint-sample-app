//
//  SitesList.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 17.05.23.
//

import SwiftUI
import AlertToast

import SDK
struct SitesList: View {
    
    @EnvironmentObject var sfm : SiteFileManager
    @EnvironmentObject var alerts : AlertController
    let logger = Logger.shared
    
    @State var list = [String]()
    @State var selectedItem:String? = nil
    @State var selectedSitefile = ""
    @State var showImporter = false
    @State var showLocalSiteFiles = false
    @State var showWebDavImporter = false
    @State var showLoading = false
    @State var showSiteFileImportAlert = false
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
            HStack{
                Button() {
                    showImporter = true
                } label: {
                    HStack{
                        Image(systemName: "folder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                        Text("Local")
                    }
                    
                }
                .padding(.trailing)
                
                Button{
                    showWebDavImporter.toggle()
                }
            label: {
                HStack{
                    Image(systemName: "server.rack")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                    Text("Remote")
                }
                
            }
                
                Spacer()
                HStack{
                    
                    Button(action: {
                        clearCache()
                        
                    }) {
                        Text("Delete all")
                            .foregroundColor(.red)
                    }
                    .disabled(list.isEmpty)
                    .padding()
                    
                }
            }
            .padding()
            
            Text("Imported Maps")
                .font(.headline)
            if showLoading {
                ProgressView()
            }
            
            if list.isEmpty {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    Image(systemName: "square.3.layers.3d.slash")
                        .resizable()
                        .scaledToFill()
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                    Text("No Maps imported")
                        .font(.headline)
                        .padding()
                    Spacer()
                }
            } else {
                
                List(list, id: \.self, selection: $selectedItem) { item in
                    Button{
                        selectedItem = item
                        if let newItem = selectedItem {
                            do {
                                try setSiteFile(item: newItem)
                                dismiss()
                            } catch {
                                showSiteFileImportAlert.toggle()
                            }
                      
                        }
                     
                    } label: {
                        Text(item)
                        
                    }
           
                    .foregroundColor(selectedSitefile != item ? .black : CustomColor.pinpoint_orange)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
        
            }

        }
        .presentationDragIndicator(.visible)
        
        .task {
            list = sfm.getSitefilesList()
        }
        
        .toast(isPresenting: $showSiteFileImportAlert){
            AlertToast(type: .error(.red), title: "Wrong Sitefile format!")
        }
        
        .sheet(isPresented: $showWebDavImporter, onDismiss: {
            list = sfm.getSitefilesList()
        }) {
            RemoteSitesList()
        }
        
        .navigationTitle("Import SiteFile")
        .navigationBarTitleDisplayMode(.inline)
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
                            do {
                                try await sfm.unarchiveFile(sourceFile: destinationUrl)
                                list = sfm.getSitefilesList()
                            } catch {
                                print("1")
                                print(error)
                                selectedFile.stopAccessingSecurityScopedResource()
                                return
                            }
                            
                            do {
                                try sfm.loadSiteFile(siteFileName: selectedFile.lastPathComponent)
                            } catch {
                                print("3")
                                print(error)
                            }
                        }
                    } else {
                        print("error saving file")
                        let error = NSError(domain: "Error saving file", code: 1001, userInfo: nil)
                        print(error)
                    }
                }
                selectedFile.stopAccessingSecurityScopedResource()
                
            } catch {
                print("2")
                print(error)
            }
        }
        
    }
    
    
    func setSiteFile(item: String) throws {
        do {
            print("setSiteFIle:  \(item)")
            try sfm.loadSiteFile(siteFileName: item)
        } catch{
            // If failed, load empty data. to avoid showing the previous map
            sfm.floorImage = UIImage()
            sfm.siteFile = SiteData()
            logger.log(type: .Error, "Error setting SiteFile: \(error)" )
            throw error
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
            sfm.siteFile = SiteData()
            sfm.floorImage = UIImage()
        } catch {
            print(error)
        }
    }
}



struct LocalSiteFileList_Previews: PreviewProvider {
    static var previews: some View {
        SitesList()
            .environmentObject(SiteFileManager())
            .environmentObject(AlertController())
    }
}








