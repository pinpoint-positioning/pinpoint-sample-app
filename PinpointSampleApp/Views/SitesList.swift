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
    @Binding var imgW:Int
    @Binding var imgH:Int
    @Binding var siteFileName:String
    @State var selection:String?
    @State var showImporter = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            List(list, id: \.self, selection: $selection) { item in
                let siteInfo = sfm.loadJson(siteFileName: item)
                Button() {
                    image = sfm.getFloorImage(siteFileName: item) ?? UIImage()
                    imgH = image.cgImage?.height ?? 0
                    imgW = image.cgImage?.width ?? 0
                    
                    if let selection = selection {
                        siteFileName = selection
                        
                    }
                       
                    
                    
                    if let siteFile = sfm.loadJson(siteFileName: item){
                        self.siteFile = siteFile
                        self.siteFileName = item
                        
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item)
                                .fontWeight((siteFileName == item) ? .bold : .regular )
                                
                            Text("Resolution: \(siteInfo?.map.mapFileRes ?? 0)")
                                .font(.system(size: 10))
                            
                            
                            Text("Site ID: \(siteInfo?.map.mapSiteId ?? "unknown")")
                                .font(.system(size: 10))
                            Text("UWB-Channel: \(siteInfo?.map.uwbChannel ?? 0)")
                                .font(.system(size: 10))
                        }
                       
                        
                        Spacer()
                        Image(uiImage: sfm.getFloorImage(siteFileName: item) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 0, maxWidth: 100, minHeight: 80, maxHeight: 80)
                    }
                    
                }
               
            }
          

            .task {
                list = sfm.getSitefilesList()
                
            }
            
            //Load Button
            Spacer()
            
            Button("Load SiteFile") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.bordered)
            
            
            
        }
        .navigationTitle("Import SiteFile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                
                // Import SiteFile
                Button() {
                    showImporter = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                
                
                
                // Delete all SiteFiles
                Button() {
                    clearCache()
                } label: {
                    Image(systemName: "xmark.bin")
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
                
                let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let destinationUrl = documentsUrl.appendingPathComponent(selectedFile.lastPathComponent)
                
                if let dataFromURL = NSData(contentsOf: selectedFile) {
                    if dataFromURL.write(to: destinationUrl, atomically: true) {
                        let sfm = SiteFileManager()
                        Task {
                            
                            _ = await sfm.unarchiveFile(sourceFile: destinationUrl)
                        }
                        
                        if let sfContent = sfm.loadJson(siteFileName: "sitedata.json") {
                            siteFile = sfContent
                        }
                        
                    } else {
                        print("error saving file")
                        let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                        print(error)
                    }
                }
                
                selectedFile.stopAccessingSecurityScopedResource()
                list = sfm.getSitefilesList()
                
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







