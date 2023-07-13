////
////  MapView.swift
////  PinpointSampleApp
////
////  Created by Christoph Scherbeck on 15.05.23.
////
//
//import SwiftUI
//import CoreLocation
//import Foundation
//import MapKit
//import SDK
//
//
//struct IdentifiablePlace: Identifiable {
//    let id: UUID
//    let location: CLLocationCoordinate2D
//    init(id: UUID = UUID(), lat: Double, long: Double) {
//        self.id = id
//        self.location = CLLocationCoordinate2D(
//            latitude: lat,
//            longitude: long)
//    }
//}
//
//struct MapView: View {
//    @State var siteFile:SiteData
//    
//    
//    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 54.91425792453898, longitude: 23.86846932733282), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
//    
//    
//    var place: IdentifiablePlace
//    
//    
//    var body: some View {
//        
//        VStack{
//
//        Map(coordinateRegion: $region)
//    }
//        
//        .task {
//            print ("lat: \(siteFile.map.originLatitude), lon: \(siteFile.map.originLongitude)")
//            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: siteFile.map.originLatitude, longitude: siteFile.map.originLongitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
//            
//        }
//        
//    }
//}
//
//
//
////struct MapView_Previews: PreviewProvider {
////    static var previews: some View {
////        MapView(place: IdentifiablePlace(lat: 51.5, long: 0))
////    }
////}
