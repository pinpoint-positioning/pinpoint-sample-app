import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13, longitude: 52),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region)
                .overlay {
                    Image("pinpoint-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100) // Adjust size as needed
                        .offset(x: 0, y: 150) // Adjust vertical offset as needed
                        .position(getMapImagePosition())
                }
              
            

        }
    }
    
    private func getMapImagePosition() -> CGPoint {
        let mapSize = UIScreen.main.bounds.size
        let mapRect = MKMapRect.world
        let mapRectWidth = mapRect.size.width
        let mapRectHeight = mapRect.size.height
        
        let imageLongitude = region.center.longitude
        let imageLatitude = region.center.latitude
        
        let x = CGFloat((imageLongitude - mapRect.origin.x) / mapRectWidth) * mapSize.width
        let y = CGFloat((mapRect.origin.y + mapRectHeight - imageLatitude) / mapRectHeight) * mapSize.height
        
        return CGPoint(x: x, y: y)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
