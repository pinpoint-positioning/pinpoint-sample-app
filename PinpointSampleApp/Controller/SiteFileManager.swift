//
//  SiteFileManager.swift
//  SDK
//
//  Created by Christoph Scherbeck on 15.05.23.
//

import Foundation
import ZIPFoundation
import SwiftUI
import SDK
import WebDAV




public class SiteFileManager: ObservableObject {
    
//    public init(){}
    @Published var siteFile = SiteData()
    @Published var floorImage = UIImage()
    
    let fileManager = FileManager()
    let logger = Logger.shared
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    // Unzip Sitefile to documentsfolder/sitefiles/sitefilename/
    
    public func unarchiveFile(sourceFile: URL) async -> Bool {
        var destinationURL = getDocumentsDirectory()
        destinationURL.appendPathComponent("sitefiles")

        // Remove ".zip" extension if it exists
        var sourceFileName = sourceFile.lastPathComponent
        if sourceFileName.lowercased().hasSuffix(".zip") {
            sourceFileName = String(sourceFileName.dropLast(4))
        }
        
        destinationURL.appendPathComponent(sourceFileName)
        
        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            print("Folder created")
            try fileManager.unzipItem(at: sourceFile, to: destinationURL)
            try await _Concurrency.Task.sleep(nanoseconds: 2_000_000_000)
            
            if let items = moveAndRenameFiles(path: destinationURL) {
                for item in items {
                    print("Found \(item)")
                }
                return true
            }
        } catch {
            print("Unzip error: \(error)")
            return false
        }
        
        return true
    }

    
    
    
    public func getSitefilesList() -> [String] {
        var destinationURL = getDocumentsDirectory()
        destinationURL.appendPathComponent("sitefiles")
        var list = [String]()
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: destinationURL.path)
            for item in items {
                print (item)
                list.append(item)
            }
            
        } catch {
            print (error)
        }
        return list
    }
    
    
    
    
    // rename floorplan and json file to standardized names
    
    func moveAndRenameFiles (path:URL) -> [String]? {
        
        let path =  path
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path.path)
            
            for item in items {
                let fileType = NSURL(fileURLWithPath: item).pathExtension
                if let fileType = fileType {
                    switch fileType {
                    case "png" :
                        do {
                            try fileManager.moveItem(atPath: path.appendingPathComponent(item).path, toPath: path.appendingPathComponent("floorplan.png").path)
                            //  logger.log(type: .Info, "Copied file from \(path.appendingPathComponent(item).path) to \(path.appendingPathComponent("floorplan.png").path) ")
                        } catch _ as NSError {
                            //  logger.log(type: .Error, "Error while copy file from \(path.appendingPathComponent(item).path) to \(path.appendingPathComponent("floorplan.png").path): \(error)")
                        }
                    case "json" :
                        do {
                            try fileManager.moveItem(atPath: path.appendingPathComponent(item).path, toPath: path.appendingPathComponent("sitedata.json").path)
                            //     logger.log(type: .Info, "Copied file from \(path.appendingPathComponent(item).path) to \(path.appendingPathComponent("sitedata.json").path) ")
                        } catch _ as NSError {
                            //  logger.log(type: .Error, "Error while copy file from \(path.appendingPathComponent(item).path) to \(path.appendingPathComponent("floorplan.png").path): \(error)")
                        }
                    default:
                        break
                        
                    }
                }
            }
            return items
        } catch {
            print(error)
            return nil
            
        }
        
    }
    
    //ParseJsonFile
    
    public func loadJson(siteFileName: String) -> SiteData {
        do {

            var destinationURL = getDocumentsDirectory()
            destinationURL.appendPathComponent("sitefiles")
            destinationURL.appendPathComponent(siteFileName)
            
            let data = try Data(contentsOf: destinationURL.appendingPathComponent("sitedata.json"))
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(SiteData.self, from: data)
            // jsonData.siteFileName = siteFileName
            return jsonData
            
        } catch {
            print("error:\(error)")
            return SiteData()
        }

    }
    
    func loadSiteFile(siteFileName: String) {
        var fileNameWithoutExtension = siteFileName
        if siteFileName.lowercased().hasSuffix(".zip") {
            fileNameWithoutExtension = String(siteFileName.dropLast(4))
        }

        siteFile = loadJson(siteFileName: fileNameWithoutExtension)
        floorImage = getFloorImage(siteFileName: fileNameWithoutExtension)
    }
    
    
    // Get the floor image file
    
    public func getFloorImage(siteFileName:String) -> UIImage {
        print("try get get sitfilename2:")
        print(siteFileName)
        var destinationURL = getDocumentsDirectory()
        destinationURL.appendPathComponent("sitefiles")
        destinationURL.appendPathComponent(siteFileName)
        destinationURL.appendPathComponent("floorplan.png")
        
        do {
            let imageData = try Data(contentsOf: destinationURL)
            return UIImage(data: imageData) ?? UIImage()
        } catch {
            print("Error loading image : \(error)")
            return UIImage()
            
        }
  
    }
    
    // "PinPoint_Debug"
    // "https://connect.pinpoint.de"
    //  "123undlos!!!"
    
    public func downloadAndSave(site: String) async -> Bool {
        @AppStorage("webdav-server") var webdavServer = ""
        @AppStorage("webdav-user") var webdavUser = ""
        @AppStorage("webdav-pw") var webdavPW = ""
        
        let wd = WebDAV()
        let account = Account(username: webdavUser, baseURL: webdavServer)
        var lastFolderName = ""
        let directoryURL = "\(site)"
        
        // extract the last folder name
        if let url = URL(string: site) {
            lastFolderName = url.lastPathComponent
        } else {
            logger.log(type: .Error, "invalid url")
            return false
        }
        
        do {
            let resources = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<[WebDAVFile]?, Error>) in
                wd.listFiles(atPath: directoryURL, account: account, password: webdavPW) { resources, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: resources)
                    }
                }
            }
            
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                logger.log(type: .Error, "Error getting documents directory.")
                return false
            }
            
            let destinationDirectoryURL = documentsDirectory.appendingPathComponent("sitefiles/\(lastFolderName)")
            
            do {
                // Create a directory in the documents directory to save the files
                try FileManager.default.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                logger.log(type: .Error, "Error creating destination directory: \(error)")
                return false
            }
            
            // Download and save JSON files
            if let jsonResources = resources?.filter({ $0.fileName.lowercased().hasSuffix(".json") }) {
                for jsonResource in jsonResources {
                    let destinationURL = destinationDirectoryURL.appendingPathComponent("sitedata.json")
                    do {
                        let data = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data?, Error>) in
                            wd.download(fileAtPath: jsonResource.path, account: account, password: "123undlos!!!") { data, error in
                                if let error = error {
                                    continuation.resume(throwing: error)
                                } else {
                                    continuation.resume(returning: data)
                                }
                            }
                        }
                        
                        if let data = data {
                            try data.write(to: destinationURL)
                            logger.log(type: .Info, "JSON file saved successfully at: \(destinationURL)")
                        } else {
                            return false
                        }
                    } catch {
                        logger.log(type: .Error, "Error saving JSON file: \(error)")
                        return false
                    }
                }
            }
            
            // Download and save PNG files
            if let pngResources = resources?.filter({ $0.fileName.lowercased().hasSuffix(".png") }) {
                for pngResource in pngResources {
                    let destinationURL = destinationDirectoryURL.appendingPathComponent("floorplan.png")
                    do {
                        let data = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data?, Error>) in
                            wd.download(fileAtPath: pngResource.path, account: account, password: "123undlos!!!") { data, error in
                                if let error = error {
                                    continuation.resume(throwing: error)
                                } else {
                                    continuation.resume(returning: data)
                                }
                            }
                        }
                        
                        if let data = data {
                            try data.write(to: destinationURL)
                            logger.log(type: .Info, "PNG file saved successfully at: \(destinationURL)")
                        } else {
                            return false
                        }
                    } catch {
                        logger.log(type: .Error, "Error saving PNG file: \(error)")
                        return false
                    }
                }
            }
            
            return true // All downloads were successful
        } catch {
            logger.log(type: .Error, "Error listing directory or downloading files: \(error)")
            return false
        }
    }
    
    
    
    
    
    enum WebDAVDownloadError: Error {
        case invalidURL
        case missingJSONFile
        case missingPNGFile
        case downloadFailed
    }
    
    
    
    
    
    
    
}





// in Progress - WebDav


// https://connect.pinpoint.de/remote.php/dav/files/PinPoint_Debug"


    public class NextcloudFileLister: NSObject, XMLParserDelegate {
        private var currentElement: String?
        private var fileNames: [String] = []
        
        @AppStorage("webdav-server") var webdavServer = ""
        @AppStorage("webdav-user") var webdavUser = ""
        @AppStorage("webdav-pw") var webdavPW = ""
        
        public func listFilesInNextcloudFolder() async -> [String]? {
            guard let serverURL =  URL(string: "\(webdavServer)/remote.php/dav/files/\(webdavUser)") else {return nil}
            let username = webdavUser
            let password = webdavPW
            let folderPath = "/sites"
            
            // Create a session configuration with credentials
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["Authorization" : "Basic " + "\(username):\(password)".data(using: .utf8)!.base64EncodedString()]
            
            // Create a session with the configuration
            let session = URLSession(configuration: configuration)
            
            // Create the WebDAV request
            var request = URLRequest(url: serverURL.appendingPathComponent(folderPath))
            request.httpMethod = "PROPFIND"
            
            do {
                // Send the WebDAV request asynchronously
                let (data, _) = try await session.data(for: request)
                
                // Parse the XML response to extract file names
                let parser = XMLParser(data: data)
                parser.delegate = self
                if parser.parse() {
                    // Parsing successful, print the file names
                    for fileName in fileNames {
                        print(fileName)
                    }
                    
                } else {
                    // Parsing failed
                    print("Error parsing XML response")
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            return fileNames
        }
        
        
        // MARK: - XMLParserDelegate
        
        public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            currentElement = elementName
        }
        
        public func parser(_ parser: XMLParser, foundCharacters string: String) {
            if currentElement == "d:href" {
                let fileName = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if !fileName.isEmpty {
                    fileNames.append(fileName)
                }
            }
        }
        
        
        
        
        
 
     
        
        
    }

