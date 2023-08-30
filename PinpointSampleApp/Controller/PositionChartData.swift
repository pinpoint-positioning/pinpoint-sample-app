//
//  PositionChartData.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 18.04.23.
//

import Foundation
import SDK

struct PositionData:Identifiable,Equatable, Hashable {
    var id = UUID()
    var x = Double()
    var y = Double()
    var acc = Double()
}

class PositionChartData:ObservableObject {

    
   static let shared = PositionChartData()
    let api = API.shared
    @Published var data = [PositionData]()
    @Published var singleXPos = 0.0
    @Published var singleYPos = 0.0

       
    
    func fillPositionArray() async  {
        
        let buffer = await api.freezeBuffer()
        
        for message in buffer {
            
            if (self.api.getCmdByte(from: message.message) == ProtocolConstants.cmdCodePosition)  {
                let position = TraceletResponse().GetPositionResponse(from: message.message)
                
                DispatchQueue.main.async {
                    
                    if (self.data.count > 11)
                    {
                        self.data.removeFirst()
                    }
                    
              //      if position.yCoord != self.data.last?.y && position.xCoord != self.data.last?.x {
                        self.data.append(PositionData(x: position.xCoord, y: position.yCoord, acc: position.accuracy))
               //     }

                }
            }
        }
    }
}


