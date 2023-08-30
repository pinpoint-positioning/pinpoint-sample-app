//
//  FloorMapOverlays.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 28.08.23.
//

import SwiftUI
import SDK


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
    @State private var allPositions: [Position] = []
    @Binding var meterToPixelRatio: CGFloat
    @Binding var imageGeo:ImageGeometry
    @Binding var settings:Settings
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    let pb = ProtobufManager.shared
    let logger = Logger()
    @StateObject var storage = LocalStorageManager()
    
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
                        .frame(width: index == latestPositionIndex ? 50 : 25, height: index == latestPositionIndex ? 50 : 25)
                        .foregroundColor(.yellow)
                        .position(x: coords.x , y: coords.y)
                        .overlay {
                            if settings.showAccuracyRange && index == latestPositionIndex {
                                AccuracyCircle(coords: coords, meterToPixelRatio:meterToPixelRatio)
                                    .position(x: coords.x, y: coords.y)
                            }
                            
                        }
                }
                
            }
        }
        .onChange(of: positions) { newValue in
            if let lastPosIndex = newValue.indices.last {
                latestPositionIndex = lastPosIndex
                if let position = positions.last {
                    if storage.remotePositioningEnabled {
                        do {
                            try pb.sendMessage(x: position.x, y: position.y, acc: position.acc, name: storage.traceletID)
                        } catch {
                            logger.log(type: .Error, error.localizedDescription)
                        }
                        
                        
                    }
                }
                
            }
        }
        .onChange(of: api.localPosition) { newPosition in
            let newPositionObject = Position(x: newPosition.xCoord, y: newPosition.yCoord, acc: newPosition.accuracy)
            if newPosition.xCoord != api.localPosition.xCoord && newPosition.yCoord != api.localPosition.yCoord{
                positions.append(newPositionObject) // Insert at the front.
                
                if positions.count > settings.previousPositions {
                    positions.removeFirst() // Remove the last element to keep the array size limited to 10.
                }
            }
            // Create a subarray containing the first ten elements
        
            
        }
    }
    
    
    func updatePositions() async {
            await pos.fillPositionArray()
            positions = pos.data.suffix(settings.previousPositions).map { Position(x: $0.x, y: $0.y, acc: $0.acc) }
            
            // Test for Origin Point Check
            // positions = [Position(x: 0, y: 0, acc: 0)]
   
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
    var meterToPixelRatio:CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                .frame(width: coords.acc * meterToPixelRatio, height: coords.acc * meterToPixelRatio)

            
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


