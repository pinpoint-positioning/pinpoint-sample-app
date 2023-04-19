//
//  PositionChartData.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 18.04.23.
//

import Foundation
import SDK

struct ChartData:Identifiable {
    var id = UUID()
    var x = Double()
    var y = Double()
}

class PositionChartData {
   static let shared = PositionChartData()
    let api = API.shared
    var data = [ChartData]()

       
    
    func getData(completion: @escaping  ((TL_PositionResponse) -> Void)) {
        
        api.freezeBuffer { buffer in
            for message in buffer {

                if (self.api.getCmdByte(from: message.message) == ProtocolConstants.cmdCodePosition)  {
                    completion(TraceletResponse().GetPositionResponse(from: message.message))

                }
                
            }
        }
    }
    
    func fillArray() {
        getData { position in
            if (self.data.count > 25)
            {
                self.data.removeFirst()
            }
            self.data.append(ChartData(x: position.xCoord, y: position.yCoord))

        }
        
    }
}


