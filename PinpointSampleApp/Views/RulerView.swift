import SwiftUI

struct RulerView: View {
    let tickHeight: CGFloat = 25
    let tickSpacing: CGFloat = 1


    @Binding var imageGeo:ImageGeometry
    @Binding var meterToPixelRatio: CGFloat

    
    var body: some View {
        GeometryReader { geometry in
            
            
            ZStack(alignment: .topLeading) {

                
                // Horizontal X-Axis
                    VStack(alignment: .center) {
                        
                        let  horizontalTickSpacing = meterToPixelRatio
                        let numberOfTicks =  Int(imageGeo.imageSize.width / meterToPixelRatio)
                        
                        HStack(alignment: .top, spacing: horizontalTickSpacing) {
                            ForEach(0..<numberOfTicks, id: \.self) { tickIndex in
                                Rectangle()
                                .fill(Color.orange)
                                .frame(width: tickIndex % 5 == 0 ? 2 : 0.5, height: imageGeo.imageSize.height)
                                .overlay {
                                    if (tickIndex % 5 == 0 ) {
                                        Text("\(tickIndex)")
                                            .position(y: -10)
                                            .font(.system(size: 10))
                                            .fixedSize(horizontal: true, vertical: false)
                                            .zIndex(10)
                                    }
                                    
                                }
                            }
                        }
                        Spacer()
                    }


                                        
                                        


                
                
                // Vertical Y-Axis
                
                HStack(alignment: .bottom) {
                    
                    let  verticalSpacing = meterToPixelRatio
                    let numberOfTicks =  Int(imageGeo.imageSize.height / meterToPixelRatio)
                   
                    VStack(alignment: .leading, spacing: verticalSpacing) {
                   
                        ForEach(0..<numberOfTicks, id: \.self) { tickIndex in
                            Rectangle()
                            .fill(Color.orange)
                            .frame(width: imageGeo.imageSize.width, height: tickIndex % 5 == 0 ? 2 : 0.5)
                            .overlay {
                                if (tickIndex % 5 == 0 ) {
                                    Text("\(numberOfTicks - tickIndex)")
                                        .position(x: -10)
                                        .font(.system(size: 10))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .zIndex(10)
                                }
                            }
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
