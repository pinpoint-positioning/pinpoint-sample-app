//
//  PositionMonitor.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 19.04.23.
//

import SwiftUI
import Charts
import SDK

struct Position: Hashable {
    let x: CGFloat
    let y: CGFloat
    let acc: CGFloat
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
    var showOrigin: Bool = true
    var showAccuracyRange:Bool = true
}


struct PositionViewFullScreen: View {
    @EnvironmentObject var api: API

    @Binding var siteFile: SiteData?
    @Binding var siteFileName: String

    @GestureState var gestureTranslation: CGSize = .zero
    @State var finalTranslation: CGSize = .zero
    @GestureState var gestureScale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    @State var meterToPixelRatio: CGFloat = 0.0
    @State var imageGeo:ImageGeometry = ImageGeometry(xOrigin: 0.0, yOrigin: 0.0, imageSize: .zero, imagePosition: .zero)
    @State var settings:Settings = Settings()
    
    @State private var isModalPresented = false
    @State private var redirectToSiteFileView = false
    var body: some View {
        NavigationStack {
 
        ZStack {
            
            Color("pinpoint_background") // Set the desired background color here
                .ignoresSafeArea()
              
            
                GeometryReader { geo in
                    let scaleFactor = finalScale * gestureScale // Calculate the scaling factor
                    HStack(alignment: .top) {
                        Rectangle()
                            .foregroundColor(Color("pinpoint_background"))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight:50)
                    }
                    .ignoresSafeArea()
                    .zIndex(1)
                    
                    // Container for the FloorImage and PositionTraceView
                    ZStack(alignment: .topLeading) {
                        

                        // Redirect to SiteFileList if no SiteFile is loaded
                        if siteFile == nil {
                            NavigationLink(destination: SitesList(siteFile: $siteFile, siteFileName: $siteFileName), isActive: $redirectToSiteFileView) {
                                EmptyView()
                            }
                            .onAppear {
                                redirectToSiteFileView = true
                            }
                        }
                        
                        
                        // MARK: - Floormap
                        
                        
                        if let image = SiteFileManager().getFloorImage(siteFileName: siteFileName) {

                            Image(uiImage: image)
                                .border(Color("pinpoint_gray"), width: 2)
                            
                                .onAppear {
                                    updateImagePosition()
                                }
                                .task {
                                    if let siteFile = siteFile {
                                        imageGeo.xOrigin = siteFile.map.mapFileOriginX
                                        imageGeo.yOrigin = siteFile.map.mapFileOriginY
                                        meterToPixelRatio = siteFile.map.mapFileRes
                                        imageGeo.imageSize = CGSize(width: image.size.width, height: image.size.height)
                                    }
                                }
                                
                        }
                        
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
                            RulerView(imageGeo: $imageGeo)
                            
                        }
                    }
                    
                    .border(Color.red)
                    .scaleEffect(scaleFactor)
                    .offset(x: imageGeo.imagePosition.x, y: imageGeo.imagePosition.y)
                    .frame(width: imageGeo.imageSize.width, height: imageGeo.imageSize.height)
                    .sheet(isPresented: $isModalPresented, content: {
                        SettingsModalView(mapSettings: $settings)
                    })
                    
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SitesList(siteFile: $siteFile, siteFileName: $siteFileName)) {
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
                    
                    

                }
            }
            
        .gesture(
            MagnificationGesture()
                .simultaneously(with: DragGesture())
                .updating($gestureScale) { value, state, _ in
                    state = value.first ?? 1.0
                }
                .updating($gestureTranslation) { value, state, _ in
                    let scaledTranslation = value.second?.translation ?? .zero
                    state = CGSize(width: scaledTranslation.width / finalScale, height: scaledTranslation.height / finalScale)
                }
                .onEnded { value in
                    finalScale *= value.first ?? 1.0
                    finalTranslation.width += value.second?.translation.width ?? 0.0
                    finalTranslation.height += value.second?.translation.height ?? 0.0
                }
                .onChanged { _ in
                    updateImagePosition()
                }
        )
            
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(siteFile?.map.mapName ?? "")
        .onAppear()
        {
            UINavigationBar.appearance().isTranslucent = false
        }
            
        }

}
    
    
    // Helper Functions

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



// WIP - Try to remove the for loop for pop up animations


//struct PositionTraceView: View {
//    @ObservedObject var pos = PositionChartData.shared
//    @EnvironmentObject var api: API
//
//    @State private var latestPositionIndex: Int?
//
//    @Binding var meterToPixelRatio: CGFloat
//    @Binding var imageGeo: ImageGeometry
//    @Binding var settings: Settings
//    @GestureState private var gestureScale: CGFloat = 1.0
//    @State private var finalScale: CGFloat = 1.0
//
//    @State private var showCircle = false
//    @State private var positions: [Position] = []
//
//    var body: some View {
//        ZStack {
//            ForEach(positions, id: \.self) { position in
//                let coords = makeCoordinates(for: position)
//                var active = true
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    Image("pinpoint-circle")
//                        .resizable()
//                        .frame(width: positions.lastIndex(of: position) == positions.count - 1 ? 20 : 10, height: positions.lastIndex(of: position) == positions.count - 1 ? 20 : 10)
//                        .foregroundColor(.yellow)
//                        .position(x: coords.x, y: coords.y)
//                        .scaleEffect(1)
//                        .opacity(active ? 1 : 0)
//                        .animation(.easeInOut(duration: 0.3), value: position)
//                        .onAppear {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                removeCircle(position)
//                                active = false
//                            }
//                        }
//                }
//            }
//            .onChange(of: api.localPosition) { _ in
//                updateCircles()
//                showCircle = true
//            }
//            .onChange(of: positions) { _ in
//                if let lastPosIndex = positions.indices.last {
//                    latestPositionIndex = lastPosIndex
//                }
//            }
//            .onAppear {
//                updatePositions()
//            }
//        }
//    }
//
//    func updateCircles() {
//        positions.append(Position(x: api.localPosition.xCoord, y: api.localPosition.yCoord, acc: api.localPosition.accuracy))
//    }
//
//    func removeCircle(_ position: Position) {
//        if let index = positions.lastIndex(of: position) {
//            withAnimation(.easeInOut(duration: 0.5)) {
//                positions.remove(at: index)
//            }
//        }
//    }
//
//    func updatePositions() {
//        Task {
//            await pos.fillPositionArray()
//            positions = pos.data.suffix(settings.previousPositions).map { Position(x: $0.x, y: $0.y, acc: $0.acc) }
//        }
//    }
//
//    func makeCoordinates(for position: Position) -> Position {
//        let scaledX = (position.x + imageGeo.xOrigin) * meterToPixelRatio
//        let scaledY = imageGeo.imageSize.height - ((position.y + imageGeo.yOrigin) * meterToPixelRatio)
//        let acc = position.acc * meterToPixelRatio
//
//        return Position(x: scaledX, y: scaledY, acc: acc)
//    }
//
//
//}











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
                        .frame(width: index == latestPositionIndex ? 20 : 10, height: index == latestPositionIndex ? 20 : 10)
                        .foregroundColor(.yellow)
                        .position(x: coords.x , y: coords.y)

                    if settings.showAccuracyRange && index == latestPositionIndex {
                        AccuracyCircle(coords: coords)
                            .position(x: coords.x, y: coords.y)
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


        return Position(x: scaledX, y: scaledY, acc: acc)
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
    @State var coords: Position
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: coords.acc , height: coords.acc)
            
            VStack {
                Text("X: \(coords.y)")
                Text("Y: \(coords.y)")
            }
            .foregroundColor(.blue)
            .font(.footnote)
            .offset(y: 25)
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
                }
            }
            .navigationTitle("Map Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
