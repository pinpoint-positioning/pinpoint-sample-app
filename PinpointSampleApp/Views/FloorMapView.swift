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

    let logger = Logger()


    var body: some View {
        

            ZStack(alignment:.bottomTrailing) {
                Color("pinpoint_background")
                    .ignoresSafeArea()
 
                    // Container for the FloorImage and PositionTraceView
                VStack(alignment:.leading) {
                    ExpandablePanel()
                   // .padding([.leading])
                    
                    
                        ScrollView ([.horizontal, .vertical]){
                            if api.scanState == .SCANNING{
                                ProgressView("Hold Tracelet close to phone")
                            } else {
                                
                                // MARK: - Floormap
                                
                                Image(uiImage:sfm.siteFile.map.mapName == "" ? blankImage() : image)
                                    .resizable()
                                    .border(Color("pinpoint_gray"), width: 2)
                                    .task {
                                        
                                        imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
    
                                        if sfm.siteFile.map.mapName == "" {
                                            meterToPixelRatio = 2
                                            imageGeo.xOrigin = 100
                                            imageGeo.yOrigin = -100
                                        }
                                    }
                                
                                    .onChange(of: api.bleState, perform: { _ in
                                        Task {
                                            await scan()
                                        }
                                        
                                    })
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
                                        image = sfm.getFloorImage(siteFileName: sfm.siteFile.map.mapName)
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
                        if storage.remotePositioningEnabled == false {
                            showAlert.toggle()
                        } else {
                            storage.remotePositioningEnabled = false
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .foregroundColor(storage.remotePositioningEnabled ? .green : .accentColor)
                        
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



class PinchZoomView: UIView {

    weak var delegate: PinchZoomViewDelgate?

    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }

    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }

    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }

    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    private var lastScale: CGFloat = 1.0


    init() {
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func pinch(gesture: UIPinchGestureRecognizer) {

        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches

        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
                numberOfTouches = gesture.numberOfTouches
            }

            scale = lastScale * gesture.scale
            if scale >= 5.0 {
                scale = 5.0
            }
            if scale <= 0.1 {
                scale = 0.1
            }

            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)

        case .ended, .cancelled, .failed:
            isPinching = false
            lastScale = scale
          //  anchor = .center
            offset = .zero
        default:
            break
        }
    }

}

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {

    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool
    

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }

    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }

    class Coordinator: NSObject, PinchZoomViewDelgate {
        var pinchZoom: PinchZoom

        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}

struct PinchToZoom: ViewModifier {
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            //.animation(isPinching ? .none : .spring())
            .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
    }
}

extension View {
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
}





