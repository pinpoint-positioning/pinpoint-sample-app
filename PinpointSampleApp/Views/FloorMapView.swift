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
import AlertToast


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
    // For scrolling to Position
    @State var currentPosition = CGPoint()
    
    @State private var showingScanResults = false
    @State private var discoveredDevices:[CBPeripheral] = []
    
    @State private var settingsPresented = false
    @State private var redirectToSiteFileView = false
    
    @State var siteListIsPresented = false
    
    @State private var showAlert = false
    @State private var scale = 0.6
    
    @StateObject var storage = LocalStorageManager.shared    
    
    // Center Image
    @State private var centerAnchor: Bool = false

    
    
    
    let pb = ProtobufManager.shared
    @State var successBump = false
    let logger = Logging()
    
    
    var body: some View {
        
        ZStack(alignment:.bottomTrailing) {
            
            VStack(alignment:.leading) {
                
                ScrollViewReader { scrollView in
                    ScrollView ([.horizontal, .vertical]){
                        
                        if api.scanState == .SCANNING{
                            
                            HoldDeviceCloseView()
                            
                        } else {
                            
                            
                            // MARK: - No Map Loaded View
                            if sfm.siteFile.map.mapName == "" {
                                NoMapLoadedView(siteListIsPresented: $siteListIsPresented)
                               
                            }
                            
                            // MARK: - Floormap
                            
                            Image(uiImage: image)
                                .resizable()
                                .border(Color("pinpoint_gray"), width: 2)
                                .id("imagecenter")
                                .onAppear {
                                    imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
                                    centerAnchor.toggle()
                                }
                            
                            
                                .onChange(of: centerAnchor) { newCenterAnchor in
                                    scrollView.scrollTo("imagecenter", anchor: .center)
                                    scale = 0.6
                                }
                            
                                .onChange(of: api.generalState, perform: { newValue in
                                    if newValue == .CONNECTED{
                                        Task {
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
                                   
                                    image = sfm.floorImage                                                                    
                                    
                                    imageGeo.xOrigin = sfm.siteFile.map.mapFileOriginX
                                    imageGeo.yOrigin = sfm.siteFile.map.mapFileOriginY
                                    meterToPixelRatio = sfm.siteFile.map.mapFileRes
                                    imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
                                    imageGeo.imagePosition = CGPoint.zero
                                    scrollView.scrollTo("imagecenter", anchor: .center)
                                    
                                    
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
                                        settings: $settings,
                                        circlePos: $currentPosition
                                    )
                                    
                                    // MARK: - Ruler
                                    
                                    if (settings.showRuler) {
                                        RulerView(imageGeo: $imageGeo, meterToPixelRatio:$meterToPixelRatio)
                                        
                                    }
                                    if(settings.showSatlets) {
                                        SatletView( imageGeo:$imageGeo, siteFile: $sfm.siteFile)
                                        
                                    }
                                    
                                }
                                .scaleEffect(scale)
                                .pinchToZoom()
                            
                        }
                        
                    }
  
                }
            }
            
            
            
            VStack(alignment: .trailing){
                
                ButtonStack(scanAction: {
                    Task {
                            await scan()
           
                    }
                },
                            centerAction: {
                    centerImage()
                }, remotePosAction:{
                    if storage.remotePositioningEnabled == false {
                        print("false")
                        showAlert = true
                    } else {
                        print("true")
                        pb.closeConnection()
                        storage.remotePositioningEnabled = false
                    }
                },  siteListAction: {
                    siteListIsPresented.toggle()
                }, size: 50)
                
            }
            .offset(y:-10)
            .padding(.vertical)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    settingsPresented = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(CustomColor.pinpoint_gray)
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
                    pb.establishConnection()
                    
                    
                },
                secondaryButton: .cancel(Text("No")) {
                    // Set the state to off if canceled
                    storage.remotePositioningEnabled = false
                }
            )
        }
        
  
        
        .sheet(isPresented: $settingsPresented, content: {
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
        
    }
    func disconnect() {
        api.disconnect()
    }
    
    func stopScan() {
        api.stopScan()
    }
    
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
                                logger.log(type: .error, error.localizedDescription)
                                
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






#Preview {
    FloorMapView()
        .environmentObject(API())
        .environmentObject(SiteFileManager())
        .environmentObject(AlertController())
    
    
}

struct HoldDeviceCloseView: View {
    var body: some View {
        VStack{
            Image("contactless-icon")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
            ProgressView("Hold Tracelet close to phone")
        }
    }
}


struct NoMapLoadedView: View {
    @Binding var siteListIsPresented:Bool
    
    var body: some View {
        VStack{
            ZStack{
                Image(systemName: "map.circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                Capsule()
                    .frame(width: 135, height: 10)
                    .rotationEffect(Angle(degrees: 145))
            }
            .foregroundColor(CustomColor.pinpoint_gray)

             
            Text("No floor plan loaded")
                .font(.headline)
                .padding()
            Spacer()
                .frame(height: 50)
            Button {
                siteListIsPresented.toggle()
            } label: {
                Text("Load floor plan")
            }
            .buttonStyle(.borderedProminent)
            
        }
        
    }
}
