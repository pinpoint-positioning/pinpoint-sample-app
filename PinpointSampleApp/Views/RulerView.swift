import SwiftUI

struct RulerView: View {
    let tickHeight: CGFloat = 25
    let tickSpacing: CGFloat = 50
    @State var numberOfTicks: Int = 50

    @Binding var imageGeo:ImageGeometry


    
    var body: some View {
        GeometryReader { geometry in
            
            
            ZStack(alignment: .topLeading) {

                
                // Horizontal X-Axis
                
                VStack(alignment: .center) {
                    let  horizontalTickSpacing = imageGeo.imageSize.width / CGFloat(numberOfTicks)
                    HStack(alignment: .top, spacing: horizontalTickSpacing) {
                        ForEach(0..<numberOfTicks, id: \.self) { tickIndex in
                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(width: tickIndex % 5 == 0 ? 2 : 0.5, height: imageGeo.imageSize.height)
                            
                        }
                    }
                   
Spacer()
                }


                
                
                // Vertical Y-Axis
                
                HStack {
                    let verticalTickSpacing = imageGeo.imageSize.height / CGFloat(numberOfTicks)
                    VStack(alignment: .leading, spacing: verticalTickSpacing) {
                        ForEach(0..<numberOfTicks, id: \.self) { tickIndex in
                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(width: imageGeo.imageSize.width,  height: tickIndex % 5 == 0 ? 2 : 0.5)
                        }
                    }
                    Spacer()
                }
            }

     
        }
    }
}




//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        RulerView(imageSize: .constant(CGSize(width: 123, height: 432)), imagePosition: .constant(CGPoint(x: 123, y: 432)))
//
//    }
//}
