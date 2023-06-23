//
//  PositionChartData.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 18.04.23.
//

import Foundation
import SDK

struct ChartData:Identifiable,Equatable, Hashable {
    var id = UUID()
    var x = Double()
    var y = Double()
    var acc = Double()
}

class PositionChartData:ObservableObject {

    
   static let shared = PositionChartData()
    let api = API.shared
    @Published var data = [ChartData]()
    @Published var singleXPos = 0.0
    @Published var singleYPos = 0.0

       
    
    func getData(completion: @escaping  ((TL_PositionResponse) -> Void)) {
        
        Task {
            let buffer = await api.freezeBuffer()
            for message in buffer {
                
                if (self.api.getCmdByte(from: message.message) == ProtocolConstants.cmdCodePosition)  {
                    completion(TraceletResponse().GetPositionResponse(from: message.message))
                    
                }
                
            }
        }
    }
    
    func fillArray() {
        getData { position in
            DispatchQueue.main.async {

                if (self.data.count > 10)
                {
                    self.data.removeFirst()
                }
             
                self.data.append(ChartData(x: position.xCoord, y: position.yCoord, acc: position.accuracy))
                self.singleXPos = position.xCoord
                self.singleYPos = position.yCoord
            
            }
            
        }
        
    }
}


