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




public class SiteFileManager {
    
    public init(){}
    
    
    let fileManager = FileManager()
    //let logger = Logger.shared
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    // Unzip Sitefile to documentsfolder/sitefiles/sitefilename/
    
    public func unarchiveFile(sourceFile:URL) async -> Bool {
        
        var destinationURL = getDocumentsDirectory()
        destinationURL.appendPathComponent("sitefiles")
        destinationURL.appendPathComponent(sourceFile.lastPathComponent)
        do {
            
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            print("folder created")
            try fileManager.unzipItem(at: sourceFile, to: destinationURL)
            try await _Concurrency.Task.sleep(nanoseconds: 2_000_000_000)
            if let items = moveAndRenameFiles(path: destinationURL) {
                for item in items {
                    print("Found \(item)")
                }
                return true
            }
            
        } catch {
            print("unzip \(error)")
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
    
    public func loadJson(siteFileName: String) -> SiteData? {
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
        }
        
        return nil
    }
    
    
    // Get the floor image file
    
    public func getFloorImage(siteFileName:String) -> UIImage? {
        var destinationURL = getDocumentsDirectory()
        destinationURL.appendPathComponent("sitefiles")
        destinationURL.appendPathComponent(siteFileName)
        destinationURL.appendPathComponent("floorplan.png")
        
        do {
            let imageData = try Data(contentsOf: destinationURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    
    public func downloadSiteFile(from url: URL) async throws -> URL {
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        
        do {
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            let destinationURL = documentsURL.appendingPathComponent("sse-demo")
            //let destinationURL = documentsURL.appendingPathComponent(tempURL.lastPathComponent)
            try fileManager.moveItem(at: tempURL, to: destinationURL)
            
            return destinationURL
        } catch {
            throw error
        }
    }
    
    
    
    
    
}





// in Progress - WebDav

    public class NextcloudFileLister: NSObject, XMLParserDelegate {
        private var currentElement: String?
        private var fileNames: [String] = []
        
        public func listFilesInNextcloudFolder() async -> [String] {
            let serverURL = URL(string: "https://connect.pinpoint.de/remote.php/dav/files/PinPoint_Debug")!
            let username = "PinPoint_Debug"
            let password = "123undlos!!!"
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

