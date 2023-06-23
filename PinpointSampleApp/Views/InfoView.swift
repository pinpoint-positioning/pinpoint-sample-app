//
//  InfoView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 21.06.23.
//

import SwiftUI

struct InfoView: View {
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    
    var body: some View {
        VStack (alignment: .leading){
            HStack{
                
                Text("Version: ")
                Spacer()
                Text(version())
      
            }
          
            HStack{
                
                Text("Compatible Tracelet Firmware: ")
                Spacer()
                Text(version())
            }
            Spacer()
        }
        .padding(.all)
        
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
