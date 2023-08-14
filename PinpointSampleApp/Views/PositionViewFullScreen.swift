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

struct Position: Hashable {
    let x: CGFloat
    let y: CGFloat
    let acc: CGFloat
    var rawX:CGFloat = 0.0
    var rawY:CGFloat = 0.0
}


struct ImageGeometry {
    var xOrigin: CGFloat
    var yOrigin: CGFloat
    var imageSize: CGSize
    var imagePosition:CGPoint
}

struct Settings {
    var previousPositions: Int = 5
    var showRuler: Bool = false
    var showOrigin: Bool = false
    var showAccuracyRange:Bool = true
    var showSatlets:Bool = false
}


struct PositionViewFullScreen: View {
    @EnvironmentObject var api : API
    @EnvironmentObject var sfm : SiteFileManager
    
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
    
    
    var body: some View {
        
        
        NavigationStack{
     
                ZStack(alignment:.bottom) {
                    Color("pinpoint_background")
                        .ignoresSafeArea()
                    
                    let scaleFactor = finalScale * gestureScale // Calculate the scaling factor
                    ScrollView([. horizontal, . vertical]){
                    // Container for the FloorImage and PositionTraceView
                    ZStack(alignment: .topLeading) {
                        
                        if api.scanState == .SCANNING {
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
                                
                                    if sfm.siteFile.map.mapName == "" {
                                        meterToPixelRatio = 5
                                        imageGeo.xOrigin = 0.0
                                        imageGeo.yOrigin = -100.0
                                    }
                                 
                                    
                                    
                                }
                                .onChange(of: api.bleState, perform: { _ in
                                    Task {
                                        await scan()
                                    }
                                    
                                })
                                .onChange(of: sfm.siteFile) { newValue in
                                    image = sfm.getFloorImage(siteFileName: sfm.siteFile.map.mapName)
                                    imageGeo.xOrigin = sfm.siteFile.map.mapFileOriginX
                                    imageGeo.yOrigin = sfm.siteFile.map.mapFileOriginY
                                    meterToPixelRatio = sfm.siteFile.map.mapFileRes
                                    imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
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
                            //   .offset(x: imageGeo.imagePosition.x, y: imageGeo.imagePosition.y)
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
                    
                  

             //       ScanAndAddButtons()
          
                }
            
            
                       .sheet(isPresented: $isModalPresented, content: {
                           SettingsModalView(mapSettings: $settings)
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
                                     await  scan()
                                   }
                               } label: {
                                   Image(systemName: "wave.3.right.circle")
                                   
                               }
                               .disabled(api.generalState == .CONNECTED ? true : false)
                           }
                           
                           
                           ToolbarItem(placement: .navigationBarTrailing) {
                               Button {
                                   isModalPresented = true
                               } label: {
                                   Image(systemName: "gear")
                                   
                               }
                           }
                           
                           ToolbarItem(placement: .navigationBarTrailing) {
                               Button {
                                   siteListIsPresented.toggle()
                               } label: {
                                   Image(systemName: "plus")
                                   
                               }
                           }
                       }

         
            
        }
        
    }
    
    
    // Helper Functions
    
    func scan() async {
        // Initiate Scan
        if api.generalState == .DISCONNECTED && api.bleState == .BT_OK{
            discoveredDevices = []
            
            api.scan(timeout: 3) { deviceList in
                if !deviceList.isEmpty {
                    discoveredDevices = deviceList
                    // Show List of devices only if there are more than 1
                    if deviceList.count > 1 {
                        showingScanResults.toggle()
                    } else {
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
                    
                    
                }
                
            }
        }
    }
    
    func blankImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 500))
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 500, height: 500))
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



struct SatletView: View {
    @ObservedObject var pos = PositionChartData.shared
    @EnvironmentObject var api: API
    @Binding var imageGeo: ImageGeometry
    @Binding var siteFile: SiteData
    
    var body: some View {
        //    imageGeo.imageSize.height  - ((positions[index].y + imageGeo.yOrigin) * meterToPixelRatio)
        
        let satletPositions = siteFile.satlets.map { CGPoint(x: ($0.xCoordinate + siteFile.map.mapFileOriginX) * siteFile.map.mapFileRes, y: imageGeo.imageSize.height - (($0.yCoordinate + siteFile.map.mapFileOriginY) * siteFile.map.mapFileRes)) }
        let _ = print("ori \(siteFile.map.mapFileOriginX) \(siteFile.map.mapFileOriginY)")
        
        ForEach(satletPositions.indices, id: \.self) { index in
            let coords = satletPositions[index]
            
            ZStack {
                Image(systemName: "wave.3.right.circle.fill")
                    .foregroundColor(.yellow)
                    .position(coords)
            }
        }
    }
}










struct PositionTraceView: View {
    @ObservedObject var pos = PositionChartData.shared
    @EnvironmentObject var api: API
    
    @State private var latestPositionIndex: Int?
    @State private var positions: [Position] = []
    @Binding var meterToPixelRatio: CGFloat
    @Binding var imageGeo:ImageGeometry
    @Binding var settings:Settings
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    
    
    var body: some View {
        ZStack {
            Text("\(meterToPixelRatio)")
         
            ForEach(positions.indices, id: \.self) { index in
                let coords = makeCoordinates(with: index)
                
                if (index > 0) {
                    Path { path in
                        let previousCoords = makeCoordinates(with: index - 1)
                        path.move(to: CGPoint(x: coords.x, y: coords.y))
                        path.addLine(to: CGPoint(x: previousCoords.x, y: previousCoords.y))
                    }
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 1, lineCap: .round))
                }
                
                
                ZStack {
                    
                    Image("pinpoint-circle")
                        .resizable()
                        .frame(width: index == latestPositionIndex ? 30 : 15, height: index == latestPositionIndex ? 30 : 15)
                        .foregroundColor(.yellow)
                        .position(x: coords.x , y: coords.y)
                        .overlay {
                            if settings.showAccuracyRange && index == latestPositionIndex {
                                AccuracyCircle(coords: coords)
                                    .position(x: coords.x, y: coords.y)
                                    .task {
                                        print(coords.x)
                                    }
                            }
                            
                        }
                    
                    
                    
                }
                
            }
        }
        .onChange(of: positions) { newValue in
            if let lastPosIndex = newValue.indices.last {
                latestPositionIndex = lastPosIndex
            }
        }
        .onChange(of: api.localPosition) { _ in
            
            updatePositions()
        }
    }
    
    func updatePositions() {
        Task {
            await pos.fillPositionArray()
            positions = pos.data.suffix(settings.previousPositions).map { Position(x: $0.x, y: $0.y, acc: $0.acc) }
            
            // Test for Origin Point Check
            // positions = [Position(x: 0, y: 0, acc: 0)]
            
        }
    }
    
    func makeCoordinates(with index: Int) -> Position {
        let scaledX = (positions[index].x + imageGeo.xOrigin) * meterToPixelRatio
        let scaledY = imageGeo.imageSize.height  - ((positions[index].y + imageGeo.yOrigin) * meterToPixelRatio)
        let acc = positions[index].acc
        let rawX = positions[index].x
        let rawY = positions[index].y
        
        
        return Position(x: scaledX, y: scaledY, acc: acc, rawX: rawX, rawY: rawY)
    }
    
    
    
}



struct CrosshairView: View {
    var body: some View {
        // Vertical Line
        VStack {
            Spacer()
            Rectangle()
                .frame(width: 3, height: 50)
                .foregroundColor(.red)
            Spacer()
        }
        
        // Horizontal Line
        HStack {
            Spacer()
            Rectangle()
                .frame(width: 50, height: 3)
                .foregroundColor(.red)
            Spacer()
        }
        
    }
}




struct AccuracyCircle: View {
    var coords: Position
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: coords.acc , height: coords.acc)
            
            VStack {
                Text("x: \(String(format: "%.1f", coords.rawX))")
                Text("y: \(String(format: "%.1f", coords.rawY))")
                Text("acc: \(String(format: "%.1f", coords.acc))")
            }
            .foregroundColor(.blue)
            .font(.footnote)
            .offset(y: 40)
        }
        
    }
}





struct SettingsModalView: View {
    @Binding var mapSettings: Settings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    Stepper(value: $mapSettings.previousPositions, in: 0...10, label: {
                        Text("Previous Positions: \(mapSettings.previousPositions)")
                    })
                    
                    Toggle(isOn: $mapSettings.showRuler) {
                        Text("Show Ruler")
                    }
                    
                    Toggle(isOn: $mapSettings.showOrigin) {
                        Text("Show Origin")
                    }
                    
                    Toggle(isOn: $mapSettings.showAccuracyRange) {
                        Text("Show Accuracy")
                    }
                    Toggle(isOn: $mapSettings.showSatlets) {
                        Text("Show Satlets")
                    }
                }
            }
            .navigationTitle("Map Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ScanAndAddButtons: View {
    @EnvironmentObject var api : API
    @State private var showingScanResults = false
    @State private var discoveredDevices:[CBPeripheral] = []
    @State var siteListIsPresented = false
    
    var body: some View {
        HStack {
            //   Spacer()
            
            Button{
                discoveredDevices = []
                showingScanResults.toggle()
                
                api.scan(timeout: 3) { deviceList in
                    
                    discoveredDevices = deviceList
                }
                
            } label: {
                
                Image(systemName: "dot.radiowaves.left.and.right")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                
                    .padding()
                    .background(CustomColor.pinpoint_orange)
                    .clipShape(Circle())
                
            }
            .shadow(radius: 2)
            
            Button {
                siteListIsPresented.toggle()
            } label: {
                
                Image(systemName: "map.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                
                    .padding()
                    .background(CustomColor.pinpoint_orange)
                    .clipShape(Circle())
            }
            
            
        }
        .sheet(isPresented: $siteListIsPresented, content: {
            SitesList()
        })
        
        
        
        // ScanList menu
        .sheet(isPresented: $showingScanResults) {
            DeviceListView(discoveredDevices: $discoveredDevices)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
