//
//  PositionMonitor.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import Charts
import SDK
import CoreBluetooth


// ToDo -> Change site from siteID




struct FloorMapView: View {
    @EnvironmentObject var api : API
    @EnvironmentObject var sfm : SiteFileManager
    @EnvironmentObject var alerts : AlertController

    
    @GestureState var gestureTranslation: CGSize = .zero
    @State var finalTranslation: CGSize = .zero
    @GestureState var gestureScale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    @State var meterToPixelRatio: CGFloat = 0.0
    @State var imageGeo:ImageGeometry = ImageGeometry(xOrigin: 0.0, yOrigin: 0.0, imageSize: .zero, imagePosition: .zero)
    @State var settings:Settings = Settings()
    @State var image = UIImage()
    
    @State private var showingScanResults = false
    @State private var discoveredDevices:[CBPeripheral] = []
    
    @State private var isModalPresented = false
    @State private var redirectToSiteFileView = false
    
    @State var siteListIsPresented = false
    
    @State private var showAlert = false
    @StateObject var storage = LocalStorageManager()
    
    
    // Center Image
    @State private var centerAnchor: Bool = false
    
    
    let logger = Logger()
    
    
    var body: some View {
        
        
        ZStack(alignment:.bottomTrailing) {
            Color("pinpoint_background")
                .ignoresSafeArea()
            
            // Container for the FloorImage and PositionTraceView
            VStack(alignment:.leading) {
                ExpandablePanel()
                ScrollViewReader { scrollView in
                    ScrollView ([.horizontal, .vertical]){
                        
                        if api.scanState == .SCANNING{
                            ProgressView("Hold Tracelet close to phone")
                        } else {
                            
                            // MARK: - Floormap
                            // For Event
                       //     Image(uiImage:sfm.siteFile.map.mapName == "" ? blankImage() : image)
                            Image(uiImage: image)
                                .resizable()
                                .border(Color("pinpoint_gray"), width: 2)
                                .task {
                                    setSiteLocalFile(item: "UBIB-IdeenReich")
                                    imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
                                    
                                    if sfm.siteFile.map.mapName == "" {
                                        meterToPixelRatio = 2
                                        imageGeo.xOrigin = 100
                                        imageGeo.yOrigin = -100
                                    }
                                    scrollView.scrollTo("center", anchor: .center)
                                    
                                }
                                .id("center") // Add an ID to this view for the center anchor
                            
                                .onChange(of: centerAnchor) { newCenterAnchor in
                                    scrollView.scrollTo("center", anchor: .center)
                                }
                                .onChange(of: api.bleState, perform: { _ in
                                    Task {
                                        await scan()
                                    }
                                    
                                })
                                .onChange(of: api.generalState, perform: { newValue in
                                    if newValue == .CONNECTED{
                                        Task {
                                            setSiteLocalFile(item: "UBIB-IdeenReich")
                                            // Set Channel of SiteFile to Tracelet if the sitefile is already loaded
                                            if sfm.siteFile.map.mapName != "" {
                                                _ = await api.setChannel(channel: Int8(sfm.siteFile.map.uwbChannel))
                                            }
                                        }
                                        alerts.showConnectedToast.toggle()
                                    }
                                    if newValue == .DISCONNECTED{
                                        alerts.showDisconnectedToast.toggle()
                                    }
                                })
                                .onChange(of: sfm.siteFile) { newValue in
                                    if storage.eventMode {
                                        if let img = sfm.getLocalFloorImage(siteFileName: sfm.siteFile.map.mapName){
                                            image = img
                                        }
                                    } else {
                                        image = sfm.getFloorImage(siteFileName: sfm.siteFile.map.mapName)
                                    }
                                    imageGeo.xOrigin = sfm.siteFile.map.mapFileOriginX
                                    imageGeo.yOrigin = sfm.siteFile.map.mapFileOriginY
                                    meterToPixelRatio = sfm.siteFile.map.mapFileRes
                                    imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
                                    imageGeo.imagePosition = CGPoint.zero
                                    
                                    
                                    Task {
                                        // Set channel according to sitefile
                                        _ =  await api.setChannel(channel:Int8(sfm.siteFile.map.uwbChannel))
                                        storage.channel = Int(sfm.siteFile.map.uwbChannel)
                                        api.startPositioning()
                                    }
                                }
                                .overlay {
                                    if (settings.showOrigin) {
                                        CrosshairView()
                                            .position(placeOrigin())
                                        
                                    }
                                    
                                    // MARK: - PositionTrace
                                    
                                    PositionTraceView(
                                        
                                        meterToPixelRatio: $meterToPixelRatio,
                                        imageGeo: $imageGeo,
                                        settings: $settings
                                    )
                                    
                                    // MARK: - Ruler
                                    
                                    if (settings.showRuler) {
                                        RulerView(imageGeo: $imageGeo, meterToPixelRatio:$meterToPixelRatio)
                                        
                                    }
                                    if(settings.showSatlets) {
                                        SatletView( imageGeo:$imageGeo, siteFile: $sfm.siteFile)
                                        
                                    }
                                    
                                }
                                .pinchToZoom()
                            
                        }
                        
                    }
                }
            }
            
            VStack(alignment: .trailing, spacing: 10){

                
                // Center Button
                FloatingButton(action: {
                    centerImage()
                }, imageName: "scope", backgroundColor: Color(uiColor: .systemGray5).opacity(0.8))
                
                // Remote Position Button
                FloatingButton(action: {
                    if storage.remotePositioningEnabled == false {
                        showAlert.toggle()
                    } else {
                        storage.remotePositioningEnabled = false
                    }
                }, imageName: "square.and.arrow.up", backgroundColor: storage.remotePositioningEnabled ? Color(uiColor: .orange).opacity(0.8) : Color(uiColor: .systemGray5).opacity(0.8))

                
                
                
            }
            .padding()
        }
        .sheet(isPresented: $isModalPresented, content: {
            SettingsView(mapSettings: $settings)
        })
        .sheet(isPresented: $showingScanResults) {
            DeviceListView(discoveredDevices: $discoveredDevices)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        
        .sheet(isPresented: $siteListIsPresented, content: {
            SitesList()
        })
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Task {
                        if api.generalState == .CONNECTED {
                            api.disconnect()
                        }
                        else if api.generalState == .DISCONNECTED {
                            await scan()
                        }
                    }
                } label: {
                    Image(systemName: "wave.3.right.circle")
                        .foregroundColor(api.generalState == .CONNECTED ? .red : .black)
                    
                }
                
            }
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    siteListIsPresented.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color.black)
                    
                }
            }
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isModalPresented = true
                } label: {
                    Image(systemName: "gear")
                        .foregroundColor(Color.black)
                    
                }
            }
            
        }
        
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("You will share your position remotely!"),
                primaryButton: .default(Text("Yes")) {
                    // Set the state to on when confirmed
                    storage.remotePositioningEnabled = true
                },
                secondaryButton: .cancel(Text("No")) {
                    // Set the state to off if canceled
                    storage.remotePositioningEnabled = false
                }
            )
        }
        
        
    }
    
    
    // Helper Functions
    
    //    func startDelayedScan() async {
    //        api.scanState = .SCANNING
    //        try? await Task.sleep(nanoseconds: 2_000_000_000) // Sleep for 3 seconds (3,000,000,000 nanoseconds)
    //        await scan()
    //    }
    
    
    func centerImage() {
        centerAnchor.toggle() // Set it to an integer value (0 in this case)
    }
    
    
    func setSiteLocalFile(item: String) {
        sfm.loadLocalSiteFile(siteFileName: item)
        if let img = sfm.getLocalFloorImage(siteFileName: item) {
            image = img
            
        }
    }
    
    func scan() async {
        // Initiate Scan
        if api.generalState == .DISCONNECTED && api.bleState == .BT_OK{
            discoveredDevices.removeAll()
            
            api.scan(timeout: 3) { deviceList in
                if !deviceList.isEmpty {
                    // If there is more than one tracelet, show the list
                    if deviceList.count > 1 {
                        showingScanResults.toggle()
                        
                    } else {
                        // If there is only one tracelet, connect to it
                        Task{
                            do {
                                if let onlyDevice = deviceList.first{
                                    let _ =  try await api.connectAndStartPositioning(device: onlyDevice)
                                    // Set fastest interval
                                    api.setPositioningInterval(interval: 1)
                                }
                            } catch {
                                logger.log(type: .Error, error.localizedDescription)
                                
                            }
                            
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        alerts.showNoTraceletInRange = true
                        
                    }
                    
                }
                discoveredDevices = deviceList
            }
        }
    }
    
//    func blankImage() -> UIImage {
//
//        let image = UIImage(named:"coordinate-system")
//        let scaledImageSize = CGSize(width: 400, height: 400)
//
//        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
//        let scaledImage = renderer.image { _ in
//            image!.draw(in: CGRect(origin: .zero, size: scaledImageSize))
//
//        }
//        return scaledImage
//
//    }
    
    private func updateImagePosition() {
        let positionX = finalTranslation.width + gestureTranslation.width
        let positionY = finalTranslation.height + gestureTranslation.height
        DispatchQueue.main.async {
            imageGeo.imagePosition = CGPoint(x: positionX, y: positionY)
        }
        
    }
    private  func placeOrigin() -> (CGPoint) {
        let scaledX = imageGeo.xOrigin * meterToPixelRatio
        let scaledY = imageGeo.imageSize.height  - (imageGeo.yOrigin * meterToPixelRatio)
        
        
        return CGPoint(x: scaledX, y: scaledY)
    }
    
}







