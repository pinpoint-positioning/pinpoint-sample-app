//
//  SitesList.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 17.05.23.
//

import SwiftUI

import SDK
struct SitesList: View {
    
    @EnvironmentObject var sfm : SiteFileManager
    
    @State var list = [String]()
    @State var selectedItem:String? = nil
    @State var selectedSitefile = ""
    @State var showImporter = false
    @State var showLocalSiteFiles = false
    @State var showWebDavImporter = false
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
            HStack{
                Button() {
                   // showLocalSiteFiles = true
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
                    Image(systemName: "cloud")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                    Text("WebDAV")
                }
              
            }
                
                Spacer()
                HStack{
                    
                    Button(action: {
                        clearCache()
                        
                    }) {
                        Image(systemName: "xmark.bin.fill")
                            .resizable()
                            .foregroundColor(.red)
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                        Text("Delete all")
                    }
                    .padding()
                
                } 
            }
            .padding()
            
            
            List(list, id: \.self, selection: $selectedItem) { item in
                Button{
                    selectedItem = item
                    selectedSitefile = item
                } label: {
                    Text(item)
                        
                }
                .foregroundColor(selectedSitefile != item ? .black : CustomColor.pinpoint_orange)
            }
            
            // Load Button
            Button(action: {
                if selectedSitefile != ""{
                    setSiteFile(item: selectedSitefile)
                    dismiss()
                }
                
            }) {
                Text("Load SiteFile")
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedSitefile == "" ? true : false)
            .padding()
 
        }
        
        
        .task {
            list = sfm.getSitefilesList()
        }
        
        .sheet(isPresented: $showWebDavImporter, onDismiss: {
            list = sfm.getSitefilesList()
        }) {
            RemoteSitesList()
        }
        
        
        .sheet(isPresented: $showLocalSiteFiles) {
           LocalSiteFileList()
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
                           _ =  await sfm.unarchiveFile(sourceFile: destinationUrl)
                            list = sfm.getSitefilesList()
                        }
                  
                        sfm.loadSiteFile(siteFileName: selectedFile.lastPathComponent)
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

    
    func setSiteFile(item: String) {
        sfm.loadSiteFile(siteFileName: item)
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



import SwiftUI

struct LocalSiteFileList: View {
    @EnvironmentObject var sfm: SiteFileManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            List {
                
                //Pinpoint Office Map
                Button(action: {
                    setSiteLocalFile(item: "Pinpoint-Office")
                    presentationMode.wrappedValue.dismiss() // Dismiss the view
                }) {
                    Text("Pinpoint-Office")
                }
                
                Button(action: {
                    setSiteLocalFile(item: "UBIB-IdeenReich")
                    presentationMode.wrappedValue.dismiss() // Dismiss the view
                }) {
                    Text("UBIB-IdeenReich")
                }
            }
        }
    }

    func setSiteLocalFile(item: String) {
        sfm.loadLocalSiteFile(siteFileName: item)
    }
}


struct LocalSiteFileList_Previews: PreviewProvider {
    static var previews: some View {
        LocalSiteFileList()
    }
}








