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


struct PositionViewFullScreen: View {
    
    
    
    @EnvironmentObject var api:API
    @Binding var siteFile:SiteData?
    @Binding var siteFileName:String
    
    @ObservedObject var pos = PositionChartData.shared
    @Binding var imgH:Int
    @Binding var imgW:Int
    
    @State var accuracy: Double?
    @State private var latestPositionIndex: Int?
    
    @State private var positions: [Position] = []
    @State private var currentPosition: Position?
    @GestureState private var gestureTranslation: CGSize = .zero
    @State private var finalTranslation: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var imageSize: CGSize = .zero
    @State var x_origin:Double = 0
    @State var y_origin:Double = 0
    let meterToPixelRatio: CGFloat = 39.0
    @State var previous_x:CGFloat = 0
    @State var previous_y:CGFloat = 0
    

    var body: some View {
        ZStack {
            Group{
                
                Image(uiImage: SiteFileManager().getFloorImage(siteFileName: siteFileName) ?? UIImage())
                    .border(Color("pinpoint_gray"), width: 2)
                    .frame(width: CGFloat(imgW), height: CGFloat(imgH))
                    .offset(x: finalTranslation.width + gestureTranslation.width,
                            y: finalTranslation.height + gestureTranslation.height)
                    .scaleEffect(finalScale * gestureScale)
                

                ForEach(positions.indices, id: \.self) { index in
                    
                    
                    let x = (CGFloat(positions[index].x + x_origin) * meterToPixelRatio)  + finalTranslation.width + gestureTranslation.width
                    let y = CGFloat(imgH) - (CGFloat(positions[index].y - y_origin)  * meterToPixelRatio)  + finalTranslation.height + gestureTranslation.height
                    
                    if (index > 0) {
                        Path() { path in
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: (CGFloat(positions[index-1].x + x_origin) * meterToPixelRatio)  + finalTranslation.width + gestureTranslation.width, y: CGFloat(imgH) - (CGFloat(positions[index-1].y - y_origin)  * meterToPixelRatio)  + finalTranslation.height + gestureTranslation.height))
                            
                        }
                        .stroke(.orange, lineWidth: 1)
                        .scaleEffect(finalScale * gestureScale)
                    }

                        Image("pinpoint-circle")

                        .resizable()
                        .frame(width: index == latestPositionIndex ? 20 : 10, height: index == latestPositionIndex ? 20 : 10)
                        .foregroundColor(.yellow)
                        .position(x: x, y: y)
                        .scaleEffect(finalScale * gestureScale)
                        .onAppear {
                            
                            latestPositionIndex = index
                            
                        }
                        .onChange(of: positions) { newValue in
                            latestPositionIndex = newValue.indices.last
                        }
                        .overlay(
                            Group {
                                if index == latestPositionIndex {
                                    let r = positions[index].acc
                                    let diameter = r * meterToPixelRatio
                                    
                                    Circle()
                                        .foregroundColor(.blue)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .opacity(0.2)
                                        .frame(width: diameter, height: diameter)
                                        .position(x: x, y: y)
                                        .scaleEffect(finalScale * gestureScale)
                                    
                                    Text(String(format: "%.1f", r))
                                        .position(x: x, y: y - 20)
                                        .foregroundColor(.blue)
                                        .scaleEffect(finalScale * gestureScale)
                                        .opacity(0.5)
   
                                }
                            }
                        )
                }

                Chart {
                    // Dummy BarMark
                    BarMark(
                        x: .value("", 0),
                        y: .value("", 0)
                    )
                    
                }
                .frame(width: Double(imgW + 50), height: Double(imgH + 50))
                .chartYScale(domain: [0, Double(imgH) / meterToPixelRatio])
                .chartXScale(domain: [0, Double(imgW) / meterToPixelRatio])
                .offset(x: finalTranslation.width + gestureTranslation.width,
                        y: finalTranslation.height + gestureTranslation.height)
                .scaleEffect(finalScale * gestureScale)
                
                
                .chartXAxis {
                    
                    AxisMarks(values: .automatic(desiredCount: (Int(finalScale * 10)))) { _ in
                        
                        AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 2, dash: [5,5]))
                            .foregroundStyle(Color.mint)
                        AxisTick(centered: true, stroke: StrokeStyle(lineWidth: 5))
                            .foregroundStyle(Color.orange)
                        AxisValueLabel()
                    }
                    
                }
                
                .chartYAxis {
                   
                    AxisMarks(position: .leading, values: .automatic(desiredCount: (Int(finalScale * 10)))) { _ in
                        AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 2, dash: [5,5]))
                            .foregroundStyle(Color.mint)
                        AxisTick(centered: true, stroke: StrokeStyle(lineWidth: 5))
                            .foregroundStyle(Color.orange)
                        AxisValueLabel()
                        
                    }
                }
                
            }
            .navigationTitle(siteFile?.map.mapName ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .task({
                if let siteFile = siteFile {
                    x_origin = siteFile.map.mapFileOriginX
                    y_origin = siteFile.map.mapFileOriginY
                    
                    
                }
            })
            
            .gesture(
                DragGesture()
                    .updating($gestureTranslation) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        finalTranslation.width += value.translation.width
                        finalTranslation.height += value.translation.height
                        
                    }
            )
            .gesture(
                MagnificationGesture()
                    .updating($gestureScale) { value, state, _ in
                        state = value
                    }
                    .onEnded { value in
                        finalScale *= value
                        
                    }
            )
            
            .onReceive(pos.objectWillChange) { _ in
                updatePositions()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
    }
    
    
    private func updatePositions() {
        positions = pos.data.suffix(10).map { Position(x: $0.x, y: $0.y, acc: $0.acc) }
    }
}
