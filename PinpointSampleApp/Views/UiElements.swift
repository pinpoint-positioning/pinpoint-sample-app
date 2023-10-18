//
//  UiElements.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 28.08.23.
//

import Foundation
import SwiftUI
import SDK


struct ListItem: View {
    
    @State var header:String
    @Binding var subText:String
    @State var symbol:String
    
    var body: some View {
        
        HStack{
            Image(systemName: symbol)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                
                Text(header)
                    .fontWeight(.semibold)
                Text(subText)
                    .fontWeight(.regular)
                    .font(.system(size: 12))
            }
        }
    }
}


struct FloatingButton: View {
    var action: () -> Void
    var imageName: String
    var backgroundColor: Color
    var size: CGSize
    
    var body: some View {
        Button(action: {
            action() // Call the closure when the button is pressed
        }) {
            Image(systemName: imageName)
                .frame(width: size.width, height: size.height)
                .scaledToFill()
                .font(.title.weight(.semibold))
                .padding()
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
                .foregroundColor(.black)
            
        }
    }
}


struct SingleFloatingButton: View {
    //  var action: () -> Void
    //   var imageName: String
    //  var backgroundColor: Color
    var size: CGSize
    
    var body: some View {
        Button(action: {
            //   action() // Call the closure when the button is pressed
        }) {
            
            ZStack{
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .circular)
                    .frame(width: size.width, height: size.height)
                    .foregroundColor(.gray.opacity(0.4))
                    .shadow(radius: 4, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: size.width * 0.6, height: size.height * 0.6)
                    .scaledToFill()
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}


struct ButtonStack: View {
    @EnvironmentObject var api : API
    var scanAction: () -> Void
    //var sytemImage1: String
    var centerAction: () -> Void
    var remotePosAction: () -> Void
   // var settingsAction: () -> Void
    var siteListAction: () -> Void
    var size: CGFloat
    var scaleFactor = 0.5
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerSize: CGSize(width: size / 6, height: size / 6), style: .circular)
                .foregroundColor(.gray.opacity(0.1))
                .blur(radius: 0.5)
                .shadow(radius: 2, x: 0, y: 2)

            VStack(spacing:size / 6){
        
                Button{
                    if api.generalState == .DISCONNECTED {
                        scanAction()
                    }
                    if api.generalState == .CONNECTED {
                        centerAction()
                    }
                } label: {
                    if api.scanState == .SCANNING {
                        ProgressView()
                            .scaledToFit()
                            .frame(width: size * scaleFactor, height: size * scaleFactor)
                            .foregroundColor(.accentColor.opacity(0.9))
                    }
                    else if api.generalState == .DISCONNECTED {
                        Image(systemName: "location")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * scaleFactor, height: size * scaleFactor)
                            .foregroundColor(.accentColor.opacity(0.9))
                    }
                    else if api.generalState == .CONNECTED {
                        Image(systemName: "location.north.line.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * scaleFactor, height: size * scaleFactor)
                            .foregroundColor(.accentColor.opacity(0.9))
                    }                   
          
                }
                
                Divider()
                
                Button{
                    siteListAction()
                } label: {
                    Image(systemName: "map")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * scaleFactor, height: size  * scaleFactor)
                        .foregroundColor(.accentColor.opacity(0.9))
                }

                
//                Divider()
//                
//                Button{
//                    settingsAction()
//                } label: {
//                    Image(systemName: "gear")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: size * scaleFactor, height: size  * scaleFactor)
//                        .foregroundColor(.accentColor.opacity(0.9))
//                }
                
                Divider()
                
                Button{
                    remotePosAction()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * scaleFactor, height: size  * scaleFactor)
                        .foregroundColor(.accentColor.opacity(0.9))
                }
         
            }
            .padding(5)
        
        }
        .frame(width: size, height: size * 2)
        .padding()
    
         
    }
}




struct MapsLikeButtonContent: View {
    
    var body: some View {
        ZStack{
            Color.green
                .ignoresSafeArea()
        
                VStack {
                       ButtonStack(scanAction: {
                           print("Button 1 tapped")
                       },
                            centerAction: {
                           print("Button 2 tapped")
                       }, remotePosAction:{
                           print("Button 2 tapped")
                       }, siteListAction: {
                           print("Button 2 tapped")
                       }, size: 50)
                   }
            }
        
    }
}


#Preview{
    MapsLikeButtonContent()
        .environmentObject(API())
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
