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




struct PositionViewFullScreen: View {
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
    
    @AppStorage("remote-positioning") var remotePositioningEnabled = false
    @AppStorage ("channel")  var channel:Int = 5
  
    
    
    var body: some View {
        
        
        NavigationStack{
            
            ZStack(alignment:.bottom) {
                Color("pinpoint_background")
                    .ignoresSafeArea()
                
                let scaleFactor = finalScale * gestureScale // Calculate the scaling factor
                
                ScrollView([. horizontal, . vertical]){
                    // Container for the FloorImage and PositionTraceView
                    ZStack(alignment: .topLeading) {
                        
                        if api.scanState == .SCANNING{
                            ProgressView("Hold Tracelet close to phone")
                        } else {
                            
                            // MARK: - Floormap
                            
                            Image(uiImage:sfm.siteFile.map.mapName == "" ? blankImage() : image)
                                .border(Color("pinpoint_gray"), width: 2)
                            
                                .onAppear {
                                    updateImagePosition()
                                }
                                .task {
                                    
                                    imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
                                    let _ = print(imageGeo.imageSize)
                                    
                                    if sfm.siteFile.map.mapName == "" {
                                        meterToPixelRatio = 2
                                        imageGeo.xOrigin = 100
                                        imageGeo.yOrigin = -100
                                    }

                                }
                                .onChange(of: api.bleState, perform: { _ in
                                    Task {
                                        await startDelayedScan()
                                    }
                                    
                                })
                                .onChange(of: api.generalState, perform: { newValue in
                                    if newValue == .CONNECTED{
                                        alerts.showConnectedToast.toggle()
                                    }
                                    if newValue == .DISCONNECTED{
                                        alerts.showDisconnectedToast.toggle()
                                    }
                                })
                                .onChange(of: sfm.siteFile) { newValue in
                                    image = sfm.getFloorImage(siteFileName: sfm.siteFile.map.mapName)
                                    imageGeo.xOrigin = sfm.siteFile.map.mapFileOriginX
                                    imageGeo.yOrigin = sfm.siteFile.map.mapFileOriginY
                                    meterToPixelRatio = sfm.siteFile.map.mapFileRes
                                    imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
                                    
                                    // Set channel according to sitefile
                                    Task {
                                       let success =  await api.setChannel(channel:Int8(sfm.siteFile.map.uwbChannel))
                                        channel = Int(sfm.siteFile.map.uwbChannel)
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
                            
                                .border(Color.black)
                                .scaleEffect(scaleFactor)
                                .frame(width: imageGeo.imageSize.width, height: imageGeo.imageSize.height)
                        }

                    }
                    .padding()
                }
                .highPriorityGesture(
                    MagnificationGesture()
                        
                        .updating($gestureScale) { value, state, _ in
                            state = value
                        }
                        .onEnded { value in
                            finalScale *= value
                        }
                        .onChanged { _ in
                            updateImagePosition()
                        }
                        
                )
   
            }
            .navigationTitle(sfm.siteFile.map.mapName)
            .navigationBarTitleDisplayMode(.inline)
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
                            .foregroundColor(api.generalState == .CONNECTED ? .red : .accentColor)
                        
                    }
                
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if remotePositioningEnabled == false {
                            showAlert.toggle()
                        } else {
                            remotePositioningEnabled = false
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .foregroundColor(remotePositioningEnabled ? .green : .accentColor)
                        
                    }
                
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        siteListIsPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                        
                    }
                }
                
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isModalPresented = true
                    } label: {
                        Image(systemName: "gear")
                        
                    }
                }
                
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("You will share your position remotely!"),
                    primaryButton: .default(Text("Yes")) {
                        // Set the state to on when confirmed
                        remotePositioningEnabled = true
                    },
                    secondaryButton: .cancel(Text("No")) {
                        // Set the state to off if canceled
                        remotePositioningEnabled = false
                    }
                )
            }
        }
        
        
    }
    
    
    // Helper Functions
    
    func startDelayedScan() async {
        api.scanState = .SCANNING
        try? await Task.sleep(nanoseconds: 2_000_000_000) // Sleep for 3 seconds (3,000,000,000 nanoseconds)
        await scan()
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
                                }
                            } catch {
                                print (error)
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
    
    func blankImage() -> UIImage {
        
        let image = UIImage(named:"coordinate-system")
        let scaledImageSize = CGSize(width: 400, height: 400)

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
                image!.draw(in: CGRect(origin: .zero, size: scaledImageSize))
            
        }
        return scaledImage

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




