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
    let logger = Logging.shared

    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    // Unzip Sitefile to documentsfolder/sitefiles/sitefilename/
    
    public func unarchiveFile(sourceFile: URL) async throws {
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
               
            }
        } catch {
            print("Unzip error: \(error)")
            throw (error)            
        }
        
    
    }
    


    
    
    public func getMapName(from fileURL: URL) throws -> String {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(SiteData.self, from: data)
            return jsonData.map.mapName
        } catch {
            print("Error: \(error)")
            throw error
        }
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
    
    func moveAndRenameFiles(path: URL) -> [String]? {
        let path = path
        let imageFileTypes = ["png", "jpg", "jpeg"]
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path.path)
            
            for item in items {
                let fileType = NSURL(fileURLWithPath: item).pathExtension
                if let fileType = fileType {
                    switch fileType.lowercased() {
                    case "json":
                        do {
                            try fileManager.moveItem(atPath: path.appendingPathComponent(item).path, toPath: path.appendingPathComponent("sitedata.json").path)
                            logger.log(type: .info, "Moved JSON file from \(path.appendingPathComponent(item).path) to \(path.appendingPathComponent("sitedata.json").path)")
                        } catch {
                            logger.log(type: .error, "Error while moving JSON file from \(path.appendingPathComponent(item).path): \(error)")
                        }
                    case let type where imageFileTypes.contains(type):
                        do {
                            let newFileName = "floorplan." + fileType
                            try fileManager.moveItem(atPath: path.appendingPathComponent(item).path, toPath: path.appendingPathComponent(newFileName).path)
                            logger.log(type: .info, "Renamed and moved image file from \(path.appendingPathComponent(item).path) to \(path.appendingPathComponent(newFileName).path)")
                        } catch {
                            logger.log(type: .error, "Error while renaming and moving image file from \(path.appendingPathComponent(item).path): \(error)")
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

    
    
    
    func loadSiteFile(siteFileName: String) throws{
        var fileNameWithoutExtension = siteFileName
        if siteFileName.lowercased().hasSuffix(".zip") {
            fileNameWithoutExtension = String(siteFileName.dropLast(4))
        }

        siteFile = loadJson(siteFileName: fileNameWithoutExtension)
        do {
            logger.log(type: .info, "Sitefile loaded:  \(fileNameWithoutExtension)")
            floorImage = try getFloorImage(siteFileName: fileNameWithoutExtension)
        } catch {
            throw error
        }
    }
    
    
    func loadLocalSiteFile(siteFileName: String) {

        siteFile = loadLocalJson(siteFileName: siteFileName)
        if let localImage = getLocalFloorImage(siteFileName: siteFileName) {
            logger.log(type: .info, "Sitefile loaded:  \(siteFileName)")
            floorImage = localImage
        }
    }
    
    
    
    
    //ParseJsonFile
    
    public func loadLocalJson(siteFileName: String) -> SiteData{
        if let asset = NSDataAsset(name: "\(siteFileName)-json", bundle: Bundle.main) {
            do {
                let jsonData = try JSONDecoder().decode(SiteData.self, from: asset.data)
                return jsonData
            } catch {
                logger.log(type: .error, "Error decoding JSON: \(error)")
                
            }
        } else {
            logger.log(type: .error, "JSON file not found: \(siteFileName)")
          
            return SiteData()
        }
        
        // Return nil in case of any error or if the JSON file is not found
        return SiteData()
    }

    
    
    public func getLocalFloorImage(siteFileName: String) -> UIImage? {
    
        if let image = UIImage(named: siteFileName) {
            return image
        } else {
            logger.log(type: .error, "error loading local image")
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
            logger.log(type: .error, "error loading json: \(error)")
            return SiteData()
        }

    }
    

    
    
    // Get the floor image file
    
    public func getFloorImage(siteFileName: String) throws -> UIImage {
        var destinationURL = getDocumentsDirectory()
        destinationURL.appendPathComponent("sitefiles")
        destinationURL.appendPathComponent(siteFileName)

        let floorplanFiles = try FileManager.default.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.lowercased().hasPrefix("floorplan") }

        guard let floorplanFile = floorplanFiles.first else {
            throw NSError(domain: "YourErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "No floorplan image found"])
        }

        do {
            let imageData = try Data(contentsOf: floorplanFile)
            logger.log(type: .info, "Loaded Floormap: \(imageData)")
            return UIImage(data: imageData) ?? UIImage()
        } catch {
            logger.log(type: .info, "Error loading image : \(error)")
            throw error
        }
    }

    
    public func downloadAndSave(site: String) async -> Bool {
        @AppStorage("webdav-server") var webdavServer = ""
        @AppStorage("webdav-user") var webdavUser = ""
        @AppStorage("webdav-pw") var webdavPW = ""
        
        let wd = WebDAV()
        let account = Account(username: webdavUser, baseURL: webdavServer)
        var lastFolderName = ""
        let directoryURL = site.removingPercentEncoding ?? site
        
        // extract the last folder nameƒ
        if let url = URL(string: site) {
            lastFolderName = url.lastPathComponent
            logger.log(type: .info, "Opening Folder: \(lastFolderName)")
        } else {
            logger.log(type: .error, "invalid url")
            return false
        }
        
        do {
          
            let resources = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<[WebDAVFile]?, Error>) in
                
                    wd.listFiles(atPath: directoryURL, account: account, password: webdavPW) { resources, error in
                        
                        print("enc")
                        print(directoryURL)
                        
                        print("res")
                        print(webdavServer + directoryURL)
                        print(account)
                        
                        if resources == nil {
                            self.logger.log(type: .error, "Could not list files in directory. Resources = \(String(describing: resources)), Dir-Path: \(directoryURL)")
                        }
                        
                        if let error = error {
                            continuation.resume(throwing: error)
                            self.logger.log(type: .error, "Error getting documents directory: \(error)")
                        } else {
                            continuation.resume(returning: resources)
                        }
                    }
                
            }
            
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                logger.log(type: .error, "Error getting documents directory.")
                return false
            }
            
            let destinationDirectoryURL = documentsDirectory.appendingPathComponent("sitefiles/\(lastFolderName)")

            do {
                // Create a directory in the documents directory to save the files
                try FileManager.default.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                logger.log(type: .error, "Error creating destination directory: \(error)")
                return false
            }

            
            // Download and save JSON files
            if let jsonResources = resources?.filter({ $0.fileName.lowercased().hasSuffix(".json") }) {
                for jsonResource in jsonResources {
                    let destinationURL = destinationDirectoryURL.appendingPathComponent("sitedata.json")
                    do {
                        let data = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data?, Error>) in
                            wd.download(fileAtPath: jsonResource.path, account: account, password: webdavPW) { data, error in
                                if let error = error {
                                    continuation.resume(throwing: error)
                                } else {
                                    continuation.resume(returning: data)
                                }
                            }
                        }
                        
                        if let data = data {
                            try data.write(to: destinationURL)
                            logger.log(type: .info, "JSON file saved successfully at: \(destinationURL)")
                        } else {
                            return false
                        }
                    } catch {
                        logger.log(type: .error, "Error saving JSON file: \(error)")
                        return false
                    }
                }
            }
            
            // Download and save image files
            let allowedFileTypes = ["png", "jpg", "jpeg"]

            if let imageResources = resources?.filter({ resource in
                let lowercasedFileName = resource.fileName.lowercased()
                return allowedFileTypes.contains { lowercasedFileName.hasSuffix(".\($0)") }
            }) {
                for imageResource in imageResources {
                    let fileExtension = (imageResource.fileName as NSString).pathExtension.lowercased()
                    let destinationFileName: String
                    logger.log(type: .info, "Accessing file type: \(fileExtension)")
                    // Determine the destination file name based on the file extension
                    switch fileExtension {
                    case "png":
                        destinationFileName = "floorplan.png"
                    case "jpg", "jpeg":
                        destinationFileName = "floorplan.jpg"
                    default:
                        // Handle other file types as needed
                        destinationFileName = "floorplan.png"
                    }
                    logger.log(type: .info, "Openened file: \(destinationFileName)")

                    let destinationURL = destinationDirectoryURL.appendingPathComponent(destinationFileName)
                    do {
                        let data = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Data?, Error>) in
                            wd.download(fileAtPath: imageResource.path, account: account, password: webdavPW) { data, error in
                                if let error = error {
                                    self.logger.log(type: .error, "Error Accessing flor map: \(error)")
                                    continuation.resume(throwing: error)
                                } else {
                                    continuation.resume(returning: data)
                                }
                            }
                        }

                        if let data = data {
                            try data.write(to: destinationURL)
                            logger.log(type: .info, "Image file saved successfully at: \(destinationURL)")
                        } else {
                            return false
                        }
                    } catch {
                        logger.log(type: .error, "Error saving image file: \(error)")
                        return false
                    }
                }
            }

            
            return true // All downloads were successful
        } catch {
            logger.log(type: .error, "Error listing directory or downloading files: \(error)")
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
        
        public func listFilesInNextcloudFolder() async throws -> [String]? {
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
                throw error
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

